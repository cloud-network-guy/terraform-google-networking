provider "google" {
  project = var.project_id
  region  = var.region
}

# Get list of zones for this region, if required
data "google_compute_zones" "all_zones" {
  count   = var.require_regional_network_tag == true ? 1 : 0
  project = var.project_id
  region  = var.region
  status  = null
}

# Set the VPC name prefix and subnet information
locals {
  url_prefix = "https://www.googleapis.com/compute/v1"
  name       = "${var.name_prefix}-${var.region}"
  subnets = flatten(concat(
    [for i in range(length(var.main_cidrs)) :
      {
        name           = "${local.name}-subnet${i + 1}"
        private_access = var.enable_private_access
        ip_range       = var.main_cidrs[i]
        secondary_ranges = concat(
          # GKE Pods Range
          [{
            name  = "gke-pods"
            range = var.gke_pods_cidrs[i]
          }],
          # GKE Services Ranges
          length(coalesce(var.gke_services_cidrs, [])) > 0 ? [for s in range(0, 29) : {
            name  = format("gke-services-%02s", s)
            range = cidrsubnet(var.gke_services_cidrs[i], var.gke_services_range_length - split("/", var.gke_services_cidrs[i])[1], s)
          }] : [],
        )
        attached_projects = toset(concat(var.subnet_attached_projects, var.attached_projects))
        shared_accounts   = toset(concat(var.subnet_shared_accounts, var.shared_accounts))
      }
    ],
    var.create_proxy_only_subnet == true && var.proxy_only_cidr != null ? [
      {
        # Proxy-only subnet for Application ILBs
        name     = "${local.name}-x-proxy-only"
        ip_range = var.proxy_only_cidr
        purpose  = var.proxy_only_purpose
      }
    ] : [],
    var.psc_prefix_base != null ? [for p in range(var.num_psc_subnets) :
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
      bgp_asn = var.cloud_router_bgp_asn
    }
  ]
  cloud_nats = [
    {
      name              = local.name
      cloud_router_name = local.name
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
        name        = "private-google-access-${local.name}"
        description = "Explicitly Route PGA range via Default Internet Gateway"
        priority    = 0
        dest_range  = "199.36.153.8/30"
        next_hop    = "default-internet-gateway"
      }
    ] : [],
    [for i, v in var.routes :
      {
        name        = "${v.name}-${local.name}"
        description = v.description
        priority    = coalesce(v.priority, 1000)
        dest_range  = v.dest_range
        dest_ranges = v.dest_ranges
        next_hop    = v.next_hop
      }
  ])
  ip_ranges = concat(
    var.enable_service_networking == true ? [
      {
        name     = "servicenetworking-${local.name}"
        ip_range = var.servicenetworking_cidr
      }
    ] : [],
    var.enable_netapp_cv == true ? [
      {
        name     = "netapp-cv-${local.name}"
        ip_range = var.netapp_cidr
      }
    ] : [],
  )
  service_connections = concat(
    var.enable_service_networking == true ? [
      {
        name      = "service-networking"
        service   = "servicenetworking.googleapis.com"
        ip_ranges = ["servicenetworking-${local.name}"]
      }
    ] : [],
    var.enable_netapp_cv == true ? [
      {
        name      = "netapp-cv"
        service   = "cloudvolumesgcp-api-network.netapp.com"
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
  source     = "../modules/vpc-networks"
  project_id = var.project_id
  region     = var.region
  vpc_networks = [
    {
      name                = local.name
      subnets             = local.subnets
      mtu                 = var.mtu
      cloud_routers       = local.cloud_routers
      cloud_nats          = local.cloud_nats
      routes              = local.routes
      ip_ranges           = local.ip_ranges
      service_connections = local.service_connections
      firewall_rules      = local.firewall_rules
    }
  ]
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
  cloud_vpn_gateways = [
    {
      name    = local.name
      network = local.name
      region  = var.region
    }
  ]
  local_vpns = [
    {
      cloud_router                    = one(local.cloud_routers).name
      cloud_vpn_gateway               = one(local.cloud_vpn_gateways).name
      peer_gcp_vpn_gateway_project_id = coalesce(var.hub_vpc.project_id, var.project_id)
      peer_gcp_vpn_gateway            = "${var.hub_vpc.network}-${var.region}"
      peer_bgp_asn                    = var.hub_vpc.bgp_asn
      advertised_ip_ranges            = [for i, v in var.main_cidrs : { range = v }]
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
      create = true
    }
  ]
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
  remote_vpn_tunnels = [
    {
      cloud_router                    = "${var.hub_vpc.network}-${var.region}"
      cloud_vpn_gateway               = "${var.hub_vpc.network}-${var.region}"
      peer_gcp_vpn_gateway_project_id = var.project_id
      peer_gcp_vpn_gateway            = one(local.cloud_vpn_gateways).name
      peer_bgp_asn                    = one(local.cloud_routers).bgp_asn
      advertised_ip_ranges            = [for i, v in var.hub_vpc.advertised_ip_ranges : { range = v }]
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
      create = true
    }
  ]
}

# Create VPN from Hub to Spoke
module "vpn-to-spoke" {
  source     = "../modules/hybrid-networking"
  project_id = var.hub_vpc.project_id
  region     = var.region
  vpns       = local.remote_vpn_tunnels
  depends_on = [module.vpn-to-hub]
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
  /*
  __psc_endpoints = [for i, v in local._psc_endpoints :
    merge(v, {
      target = {
        project_id = coalesce(v.target.project_id, v.target_id != null ? element(reverse(split("/", v.target_id)), 4) : v.project_id)
        region     = coalesce(v.target.region, v.target_id != null ? element(reverse(split("/", v.target_id)), 2) : v.region)
        name       = coalesce(v.target.name, v.target_id != null ? element(reverse(split("/", v.target_id)), 0) : null)
      }
    })
  ]
  ___psc_endpoints = [for i, v in local.__psc_endpoints :
    merge(v, {
      target_id = coalesce(v.target_id, "projects/${v.target.project_id}/regions/${v.target.region}/serviceAttachments/${v.target.name}")
    })
  ]
  psc_endpoints = [for i, v in local.___psc_endpoints :
    merge(v, {
     ip_address_name        = coalesce(v.ip_address_name, "psc-endpoint-${v.target.region}-${v.target.name}")
      ip_address_description = coalesce(v.ip_address_description, "PSC to ${v.target_id}")
    })
  ]
  */
}

module "psc-endpoints" {
  source                 = "../modules/lb-frontend"
  for_each               = { for k, v in local.psc_endpoints : "${v.project_id}/${v.region}/${v.name}" => v }
  type                   = "INTERNAL"
  project_id             = each.value.project_id
  host_project_id        = each.value.host_project_id
  region                 = each.value.region
  ip_address             = each.value.ip_address
  ip_address_name        = each.value.ip_address_name
  ip_address_description = each.value.ip_address_description
  network                = each.value.network
  subnet                 = each.value.subnet
  name                   = each.value.name
  description            = each.value.description
  target                 = each.value.target
  global_access          = false
  depends_on             = [module.vpc-network]
}
