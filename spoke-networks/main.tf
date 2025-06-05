locals {
  url_prefix = "https://www.googleapis.com/compute/v1"
  create     = coalesce(var.create, true)
  project    = lower(trimspace(coalesce(var.project_id, var.project)))
  region     = var.region != null ? lower(trimspace(var.region)) : null
}

# Get list of zones for this region, if required
data "google_compute_zones" "all_zones" {
  count   = var.require_regional_network_tag == true ? 1 : 0
  project = local.project
  region  = local.region
  status  = null
}

# Set the VPC name prefix and subnet information
locals {
  name = "${var.name_prefix}-${local.region}"
  subnets = flatten(concat(
    [for i, v in var.subnets :
      {
        name           = "${local.name}-subnet${i + 1}"
        private_access = var.enable_private_access
        ip_range       = v.main_cidr
        secondary_ranges = concat(
          # GKE Pods Range
          [
            {
              name  = "gke-pods"
              range = v.gke_pods_cidr
            }
          ],
          # GKE Services Ranges
          v.gke_services_cidr != null ? [
            for s in range(0, 29) : {
              name  = format("gke-services-%02s", s)
              range = cidrsubnet(v.gke_services_cidr, var.gke_services_range_length - split("/", v.gke_services_cidr)[1], s)
            }
          ] : [],
        )
        attached_projects = concat(v.attached_projects, var.attached_projects)
        shared_accounts   = concat(v.shared_accounts, var.shared_accounts)
        viewer_accounts   = concat(v.viewer_accounts, var.viewer_accounts)
      }
    ],
    local.create && var.create_proxy_only_subnet == true && var.proxy_only_cidr != null ? [
      {
        # Proxy-only subnet for Application ILBs
        name     = "${local.name}-x-proxy-only"
        ip_range = var.proxy_only_cidr
        purpose  = var.proxy_only_purpose
      }
    ] : [],
    local.create && var.psc_prefix_base != null ? [for p in range(var.num_psc_subnets) :
      {
        # Also add PSC subnets
        name     = "${local.name}-x-psc-${format("%02s", p)}"
        ip_range = cidrsubnet(var.psc_prefix_base, var.psc_subnet_length - split("/", var.psc_prefix_base)[1], p)
        purpose  = var.psc_purpose
      }
    ] : []
  ))
  cloud_routers = [
    {
      name    = local.name
      region  = var.region
      bgp_asn = var.cloud_router_bgp_asn
    }
  ]
  cloud_nats = [
    {
      name   = local.name
      region = var.region
      router = local.name
      static_ips = [for i, v in range(0, var.cloud_nat_num_static_ips) :
        {
          description = "External Static IP for Cloud NAT"
        }
      ]
      min_ports_per_vm = var.cloud_nat_min_ports_per_vm
      max_ports_per_vm = var.cloud_nat_max_ports_per_vm
      log_type         = var.cloud_nat_log_type
    }
  ]
  routes = concat(
    var.enable_private_access == true ? [
      {
        name             = "private-google-access-${local.name}"
        description      = "Explicitly Route PGA range via Default Internet Gateway"
        priority         = 0
        dest_range       = "199.36.153.8/30"
        next_hop_gateway = "default-internet-gateway"
      }
    ] : [],
    [for i, v in var.routes :
      {
        name             = "${v.name}-${local.name}"
        description      = v.description
        priority         = coalesce(v.priority, 1000)
        dest_range       = v.dest_range
        dest_ranges      = v.dest_ranges
        next_hop_gateway = v.next_hop
      }
  ])
  ip_ranges = concat(
    local.create && var.enable_service_networking == true ? [
      {
        name     = "servicenetworking-${local.name}"
        ip_range = var.servicenetworking_cidr
      }
    ] : [],
    local.create && var.enable_netapp_cv == true ? [
      {
        name     = "netapp-cv-${local.name}"
        ip_range = var.netapp_cidr
      }
    ] : [],
  )
  service_connections = concat(
    local.create && var.enable_service_networking == true ? [
      {
        name      = "service-networking"
        service   = "servicenetworking.googleapis.com"
        ip_ranges = ["servicenetworking-${local.name}"]
      }
    ] : [],
    local.create && var.enable_netapp_cv == true ? [
      {
        name      = "netapp-cv"
        service   = "cloudvolumesgcp-api-network.netapp.com"
        ip_ranges = ["netapp-cv-${local.name}"]
      }
    ] : [],
    local.create && var.enable_netapp_gcnv == true ? [
      {
        name      = "netapp-gcnv"
        service   = "netapp.servicenetworking.goog"
        ip_ranges = ["netapp-cv-${local.name}"]
      }
    ] : [],
  )
  region_and_zone_names = concat([var.region], try(one(data.google_compute_zones.all_zones).names, []))
  firewall_rules = concat([for i, v in var.firewall_rules : merge(v, { name = "${local.name}-${v.name}" })],
    var.enable_private_access == true ? [
      {
        name        = "${local.name}-private-google-access-egress"
        description = "Allow egress to Private Google Access IP Ranges"
        direction   = "EGRESS"
        priority    = 1
        range_types = ["private-googleapis"]
        action      = "allow"
        logging     = false
      }
    ] : [],
    var.allow_internal_ingress == true ? [
      {
        name          = "${local.name}-internal-ingress"
        description   = "Allow Ingress from Internal IP Ranges"
        direction     = "INGRESS"
        priority      = 1001
        target_tags   = var.require_regional_network_tag == true ? local.region_and_zone_names : null
        source_ranges = var.internal_ips
        action        = "allow"
        logging       = var.log_internal_ingress
      },
    ] : [],
    var.allow_external_ingress == true ? [
      {
        name          = "${local.name}-external-ingress"
        description   = "Allow Ingress from External IP Ranges"
        direction     = "INGRESS"
        priority      = 1002
        target_tags   = var.require_regional_network_tag == true ? local.region_and_zone_names : null
        source_ranges = ["0.0.0.0/0"]
        action        = "allow"
        logging       = var.log_external_ingress
      },
    ] : [],
    var.allow_internal_egress == true ? [
      {
        name               = "${local.name}-internal-egress"
        description        = "Allow Egress to Internal IP Ranges"
        direction          = "EGRESS"
        priority           = 1001
        target_tags        = var.require_regional_network_tag == true ? local.region_and_zone_names : null
        destination_ranges = var.internal_ips
        action             = "allow"
        logging            = var.log_internal_egress
      },
    ] : [],
    var.allow_external_egress == true ? [
      {
        name               = "${local.name}-external-egress"
        description        = "Allow Egress to External IP Ranges"
        direction          = "EGRESS"
        priority           = 1002
        target_tags        = var.require_regional_network_tag == true ? local.region_and_zone_names : null
        destination_ranges = ["0.0.0.0/0"]
        action             = "allow"
        logging            = var.log_external_egress
      },
    ] : [],
    var.create_proxy_only_subnet == true && var.proxy_only_cidr != null ? [
      {
        name          = "${local.name}-snat-proxy-only"
        description   = "Allow ingress from Proxy Only / Regional Managed Proxy Subnets"
        direction     = "INGRESS"
        priority      = 1
        action        = "allow"
        source_ranges = [var.proxy_only_cidr]
        allow         = [{ protocol : "tcp", ports : ["1-65535"] }]
        logging       = false
      },
    ] : [],
    var.psc_prefix_base != null && var.num_psc_subnets > 0 ? [
      {
        name          = "${local.name}-snat-psc"
        description   = "Allow ingress from PSC Subnets"
        direction     = "INGRESS"
        priority      = 1
        action        = "allow"
        source_ranges = [var.psc_prefix_base]
        allow         = [{ protocol : "tcp", ports : ["1-65535"] }, { protocol : "udp", ports : ["1-65535"] }]
        logging       = false
      },
    ] : [],
  )
}

# Create VPC network and related resources
module "vpc-network" {
  source                  = "../modules/vpc-network"
  project_id              = var.project_id
  create                  = local.create
  name                    = local.name
  description             = null
  mtu                     = var.mtu
  auto_create_subnetworks = false
  global_routing          = false
  default_region          = var.region
  subnets                 = local.subnets
  cloud_routers           = local.cloud_routers
  cloud_nats              = local.cloud_nats
  peerings                = []
  routes                  = local.routes
  ip_ranges               = local.ip_ranges
  service_connections     = local.service_connections
  firewall_rules          = local.firewall_rules
}

# Shared VPC Permissions
locals {
  shared_subnetworks = [for subnet in local.subnets :
    {
      id                = one([for s in module.vpc-network.subnets : s.id if s.name == subnet.name && s.region == var.region])
      name              = one([for s in module.vpc-network.subnets : s.name if s.name == subnet.name && s.region == var.region])
      region            = one([for s in module.vpc-network.subnets : s.region if s.name == subnet.name && s.region == var.region])
      purpose           = one([for s in module.vpc-network.subnets : s.purpose if s.name == subnet.name && s.region == var.region])
      attached_projects = lookup(subnet, "attached_projects", [])
      shared_accounts   = lookup(subnet, "shared_accounts", [])
      viewer_accounts   = lookup(subnet, "viewer_accounts", [])
    }
  ]
}
module "shared-vpc" {
  source          = "../modules/shared-vpc"
  host_project_id = var.project_id
  network         = module.vpc-network.name
  region          = var.region
  subnetworks     = local.create ? [for s in local.shared_subnetworks : s if s.purpose == "PRIVATE"] : []
}

# Generate a random 20-character string to be used for the IKE shared secret
resource "random_string" "ike_psks" {
  for_each = { for i, v in range(0, 2) : i => v }
  length   = 20
  special  = false
}

# Select random IPs for the Tunnel interior IP addresses
resource "random_integer" "tunnel_third_octet" {
  min = 10
  max = 253
}
resource "random_integer" "tunnel_fourth_octet_base" {
  min = 0
  max = 31
}

locals {
  tunnel_third_octet       = random_integer.tunnel_third_octet.result
  tunnel_fourth_octet_base = random_integer.tunnel_fourth_octet_base.result * 8
  cloud_vpn_gateways = local.create ? [
    {
      name    = local.name
      network = local.name
      region  = var.region
    }
  ] : []
  local_vpns = local.create ? [
    {
      cloud_router                    = one(local.cloud_routers).name
      cloud_vpn_gateway               = one(local.cloud_vpn_gateways).name
      peer_gcp_vpn_gateway_project_id = coalesce(var.hub_vpc.project_id, var.project_id)
      peer_gcp_vpn_gateway            = coalesce(var.hub_vpc.cloud_vpn_gateway, "${var.hub_vpc.network}-${var.region}")
      peer_bgp_asn                    = var.hub_vpc.bgp_asn
      advertised_ip_ranges = flatten([for i, v in var.subnets :
        [
          {
            range       = v.main_cidr
            description = v.name
          }
        ]
      ])
      tunnels = [for i in range(0, 2) :
        {
          name                = "${local.name}-${var.hub_vpc.network}-${i}"
          ike_psk             = random_string.ike_psks[i].result
          interface_name      = "if-${local.name}-${var.hub_vpc.network}-${i}"
          cloud_router_ip     = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4 + 1)}/30"
          peer_bgp_ip         = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4 + 2)}"
          peer_bgp_name       = "${local.name}-${var.hub_vpc.network}-${i}"
          advertised_priority = 100 + i
        }
      ]
    }
  ] : []
}
# Create VPN connection from Spoke to Hub
module "vpn-to-hub" {
  source             = "../modules/hybrid-networking"
  project_id         = var.project_id
  region             = var.region
  cloud_vpn_gateways = local.cloud_vpn_gateways
  vpns               = local.local_vpns
  depends_on         = [module.vpc-network]
}

locals {
  remote_vpn_tunnels = local.create ? [
    {
      cloud_router                    = coalesce(var.hub_vpc.cloud_router, "${var.hub_vpc.network}-${var.region}")
      cloud_vpn_gateway               = coalesce(var.hub_vpc.cloud_vpn_gateway, "${var.hub_vpc.network}-${var.region}")
      peer_gcp_vpn_gateway_project_id = var.project_id
      peer_gcp_vpn_gateway            = one(local.cloud_vpn_gateways).name
      peer_bgp_asn                    = one(local.cloud_routers).bgp_asn
      advertised_ip_ranges            = [for i, v in coalesce(var.hub_vpc.advertised_ip_ranges, var.internal_ips) : { range = v }]
      tunnels = [for i in range(0, 2) :
        {
          name                = "${local.name}-${i}"
          ike_psk             = random_string.ike_psks[i].result
          interface_name      = "if-${local.name}-${i}"
          cloud_router_ip     = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4 + 2)}/30"
          peer_bgp_ip         = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4 + 1)}"
          peer_bgp_name       = "${local.name}-${i}"
          advertised_priority = 100 + i
        }
      ]
    }
  ] : []
}

# Create VPN from Hub to Spoke
module "vpn-to-spoke" {
  source     = "../modules/hybrid-networking"
  project_id = var.hub_vpc.project_id
  region     = var.region
  vpns       = local.remote_vpn_tunnels
  depends_on = [module.vpc-network, module.vpn-to-hub]
}

# PSC Consumer Endpoints
locals {
  # Create PSC Consumer Endpoints inside each region for each service
  psc_endpoints = [for i, v in var.psc_endpoints :
    merge(v, {
      project_id      = coalesce(v.project_id, var.project_id)
      host_project_id = var.project_id
      network         = local.name
      region          = var.region
      target          = startswith(v.target, local.url_prefix) ? v.target : "${local.url_prefix}/${v.target}"
    })
  ]
}
module "psc-endpoints" {
  source              = "../modules/forwarding-rule"
  for_each            = { for k, v in local.psc_endpoints : "${v.project_id}/${v.region}/${v.name}" => v }
  create              = local.create
  project_id          = each.value.project_id
  host_project_id     = each.value.host_project_id
  name                = each.value.name
  description         = each.value.description
  region              = each.value.region
  address             = each.value.ip_address
  address_name        = each.value.ip_address_name
  address_description = each.value.ip_address_description
  network             = each.value.network
  subnetwork          = each.value.subnet
  target              = each.value.target
  global_access       = false
  depends_on          = [module.vpc-network]
}
