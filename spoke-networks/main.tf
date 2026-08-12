locals {
  url_prefix                           = "https://www.googleapis.com/compute/v1"
  create                               = coalesce(var.create, true)
  project                              = lower(trimspace(coalesce(var.project_id, var.project)))
  region                               = var.region != null ? lower(trimspace(var.region)) : null
  enable_service_networking            = coalesce(var.enable_service_networking, false)
  enable_netapp                        = anytrue([var.enable_netapp, var.enable_netapp_cv, false])
  enable_netapp_cv                     = coalesce(var.enable_netapp_cv, false)
  advertise_servicenetworking_ip_range = coalesce(var.advertise_servicenetworking_ip_range, false)
  advertise_netapp_ip_range            = coalesce(var.advertise_netapp_ip_range, false)
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
        purpose           = "PRIVATE"
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
    local.create && local.enable_service_networking ? [
      {
        name     = "servicenetworking-${local.name}"
        ip_range = var.servicenetworking_cidr
      }
    ] : [],
    local.create && local.enable_netapp ? [
      {
        name     = "netapp-cv-${local.name}"
        ip_range = var.netapp_cidr
      }
    ] : [],
  )
  service_connections = concat(
    local.create && local.enable_service_networking ? [
      {
        name      = "service-networking"
        service   = "servicenetworking.googleapis.com"
        ip_ranges = [for _ in local.ip_ranges : _.name if _.name == "servicenetworking-${local.name}"]
      }
    ] : [],
    local.create && local.enable_netapp ? [
      {
        name      = "netapp-gcnv"
        service   = "netapp.servicenetworking.goog"
        ip_ranges = [for _ in local.ip_ranges : _.name if _.name == "netapp-cv-${local.name}"]
      }
    ] : [],
    local.create && local.enable_netapp && local.enable_netapp_cv ? [
      {
        name      = "netapp-cv"
        service   = "cloudvolumesgcp-api-network.netapp.com"
        ip_ranges = [for _ in local.ip_ranges : _.name if _.name == "netapp-cv-${local.name}"]
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
  project_id              = local.project
  create                  = local.create
  name                    = local.name
  description             = null
  mtu                     = var.mtu
  auto_create_subnetworks = false
  global_routing          = false
  default_region          = local.region
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
  source                         = "../modules/shared-vpc"
  host_project_id                = local.project
  network                        = module.vpc-network.name
  region                         = local.region
  subnetworks                    = local.create ? [for s in local.shared_subnetworks : s if s.purpose == "PRIVATE"] : []
  give_gke_project_viewer_access = var.give_gke_project_viewer_access
}

# Generate a random 20-character string to be used for the IKE shared secret
resource "random_string" "ike_psks" {
  for_each = { for i, v in range(0, 2) : i => v }
  length   = 20
  special  = false
}

# Create an HA VPN Gateway in the local project
resource "google_compute_ha_vpn_gateway" "default" {
  gateway_ip_version = "IPV4"
  name               = local.name
  network            = module.vpc-network.self_link
  project            = local.project
  region             = local.region
  stack_type         = "IPV4_ONLY"
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

# Configure HA VPNs from Spoke to Hub and vice-versa
locals {
  tunnel_third_octet       = random_integer.tunnel_third_octet.result
  tunnel_fourth_octet_base = random_integer.tunnel_fourth_octet_base.result * 8
  interface_ip_prefix      = "169.254.${local.tunnel_third_octet}"
  # VPN Tunnels from Spoke to Hub
  spoke_vpn_tunnels = [for i in range(0, 2) :
    {
      tunnel_index     = i
      index_key        = "spoke-${i}"
      name             = "${local.name}-${var.hub_vpc.network}-${i}"
      project          = local.project
      router           = one(local.cloud_routers).name
      vpn_gateway      = google_compute_ha_vpn_gateway.default.self_link
      peer_gcp_gateway = "projects/${var.hub_vpc.project_id}/regions/${local.region}/vpnGateways/${coalesce(var.hub_vpc.cloud_vpn_gateway, "${var.hub_vpc.network}-${local.region}")}"
      ip_range         = "${local.interface_ip_prefix}.${local.tunnel_fourth_octet_base + (i * 4 + 1)}/30"
      peer_ip_address  = "${local.interface_ip_prefix}.${local.tunnel_fourth_octet_base + (i * 4 + 2)}"
      interface_name   = "if-${local.name}-${var.hub_vpc.network}-${i}"
      peer_name        = "${local.name}-${var.hub_vpc.network}-${i}"
      peer_asn         = var.hub_vpc.bgp_asn
      advertised_ip_ranges = concat(
        coalescelist(
          [for ip_range in var.advertised_ip_ranges :
            { range = ip_range }
          ],
          [for subnet in local.subnets :
            { range = subnet.ip_range, description = subnet.name }
          if subnet.purpose == "PRIVATE"]
        ),
        local.advertise_servicenetworking_ip_range ? [
          { range = var.servicenetworking_cidr, description = "Service Networking PSA Range" }
        ] : [],
        local.advertise_netapp_ip_range ? [
          { range = var.netapp_cidr, description = "NetApp PSA Range" }
        ] : [],
      )

    }
  ]
  # VPN Tunnels from Hub to Spoke
  hub_vpn_tunnels = [for i in range(0, 2) :
    {
      tunnel_index         = i
      index_key            = "hub-${i}"
      name                 = "${local.name}-${i}"
      project              = var.hub_vpc.project_id
      router               = coalesce(var.hub_vpc.cloud_router, "${var.hub_vpc.network}-${local.region}")
      vpn_gateway          = coalesce(var.hub_vpc.cloud_vpn_gateway, "${var.hub_vpc.network}-${local.region}")
      peer_gcp_gateway     = google_compute_ha_vpn_gateway.default.self_link
      ip_range             = "${local.interface_ip_prefix}.${local.tunnel_fourth_octet_base + (i * 4 + 2)}/30"
      peer_ip_address      = "${local.interface_ip_prefix}.${local.tunnel_fourth_octet_base + (i * 4 + 1)}"
      interface_name       = "if-${local.name}-${i}"
      peer_name            = "${local.name}-${i}"
      peer_asn             = one(local.cloud_routers).bgp_asn
      advertised_ip_ranges = [for i, v in coalesce(var.hub_vpc.advertised_ip_ranges, var.internal_ips) : { range = v }]
    }
  ]
  vpn_tunnels = {
    for i, v in concat(local.spoke_vpn_tunnels, local.hub_vpn_tunnels) : v.index_key => v
  }
}

# VPN Tunnels
resource "google_compute_vpn_tunnel" "default" {
  for_each              = local.vpn_tunnels
  ike_version           = 2
  name                  = each.value.name
  peer_gcp_gateway      = each.value.peer_gcp_gateway
  project               = each.value.project
  region                = local.region
  router                = each.value.router
  shared_secret         = random_string.ike_psks[each.value.tunnel_index].result
  vpn_gateway           = each.value.vpn_gateway
  vpn_gateway_interface = each.value.tunnel_index
  depends_on            = [module.vpc-network]
}
# Router interfaces for VPN Tunnels
resource "google_compute_router_interface" "default" {
  for_each   = local.vpn_tunnels
  ip_range   = each.value.ip_range
  name       = each.value.interface_name
  project    = each.value.project
  region     = local.region
  router     = each.value.router
  vpn_tunnel = google_compute_vpn_tunnel.default[each.key].self_link
}
# BGP Peer sessions for VPN Tunnels
resource "google_compute_router_peer" "default" {
  for_each                           = local.vpn_tunnels
  advertise_mode                     = "CUSTOM"
  advertised_groups                  = []
  advertised_route_priority          = 100 + each.value.tunnel_index
  enable_ipv4                        = true
  enable_ipv6                        = false
  interface                          = google_compute_router_interface.default[each.key].name
  name                               = each.value.peer_name
  peer_asn                           = each.value.peer_asn
  peer_ip_address                    = each.value.peer_ip_address
  project                            = each.value.project
  region                             = local.region
  router                             = each.value.router
  zero_custom_learned_route_priority = false
  dynamic "advertised_ip_ranges" {
    for_each = each.value.advertised_ip_ranges
    content {
      range       = advertised_ip_ranges.value.range
      description = lookup(advertised_ip_ranges.value, "description", null)
    }
  }
}

# PSC Consumer Endpoints
locals {
  psc_consumers = [for i, endpoint in coalesce(var.psc_consumers, []) :
    {
      create              = local.create ? coalesce(endpoint.create, true) : false
      project             = coalesce(endpoint.project, local.project)
      name                = coalesce(endpoint.name, "psc-consumer-${i}")
      address             = endpoint.address
      address_name        = endpoint.address_name
      address_description = endpoint.address_description
      region              = local.region
      subnetwork          = endpoint.subnetwork
      target              = startswith(endpoint.target, local.url_prefix) ? endpoint.target : "${local.url_prefix}/${endpoint.target}"
      global_access       = coalesce(endpoint.global_access, false)
    }
  ]
}
module "psc-consumers" {
  source              = "../modules/forwarding-rule"
  for_each            = { for k, v in local.psc_consumers : "${v.project}/${v.region}/${v.name}" => v }
  create              = each.value.create
  project             = each.value.project
  host_project        = local.project
  type                = "INTERNAL"
  name                = each.value.name
  address             = each.value.address
  address_name        = each.value.address_name
  address_description = each.value.address_description
  region              = each.value.region
  subnetwork          = each.value.subnetwork
  set_null_subnetwork = true
  target              = each.value.target
  global_access       = each.value.global_access
  network             = module.vpc-network.self_link
}


