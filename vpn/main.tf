locals {
  create            = coalesce(var.create, true)
  project           = lower(trimspace(coalesce(var.project_id, var.project)))
  region            = var.region != null ? lower(trimspace(var.region)) : null
  router            = var.router != null ? lower(trimspace(var.router)) : null
  network           = var.network != null ? lower(trimspace(var.network)) : null
  cloud_vpn_gateway = var.cloud_vpn_gateway != null ? lower(trimspace(var.cloud_vpn_gateway)) : null
  peer_vpn_gateways = { for k, v in var.peer_vpn_gateways :
    k => {
      create      = v.create
      name        = lower(trimspace(coalesce(v.name, k)))
      description = v.description
      bgp_asn     = v.bgp_asn
      interfaces = [for i, interface in v.interfaces :
        {
          id          = i
          ip_address  = trimspace(interface.ip_address)
          description = coalesce(interface.description, "interface ${i}")
          bgp_asn     = coalesce(interface.bgp_asn, v.bgp_asn)
        }
      ]
      redundancy_type = length(v.interfaces) >= 2 ? "TWO_IPS_REDUNDANCY" : "SINGLE_IP_INTERNALLY_REDUNDANT"
    } if v.create
  }
}

# Query Cloud VPN Gateway to get its public IP addresses 
data "google_compute_ha_vpn_gateway" "default" {
  #for_each = { for k, v in local.ha_vpn_gateways : k => v }
  project = local.project
  region  = local.region
  name    = local.cloud_vpn_gateway
}

# Create a null for each VPN gateway to force total destruction before re-creation
resource "null_resource" "peer_vpn_gateways" {
  for_each = { for i, v in local.peer_vpn_gateways : v.name => true }
}
resource "google_compute_external_vpn_gateway" "default" {
  for_each        = { for k, v in local.peer_vpn_gateways : v.name => v }
  project         = local.project
  name            = each.value.name
  description     = each.value.description
  redundancy_type = each.value.redundancy_type
  dynamic "interface" {
    for_each = each.value.interfaces
    content {
      id         = interface.value.id
      ip_address = interface.value.ip_address
    }
  }
  depends_on = [null_resource.peer_vpn_gateways]
}

locals {
  routers = compact([local.router])
}
data "google_compute_router" "default" {
  for_each = toset(local.network != null ? local.routers : [])
  project  = local.project
  network  = local.network
  region   = local.region
  name     = each.value
}

locals {
  vpns = [for vpn_key, vpn in var.vpns :
    merge(vpn, {
      name = lower(trimspace(coalesce(vpn.name, vpn_key))
    ) })
  ]
  vpn_tunnels = flatten(
    [for vpn_key, vpn in local.vpns :
      [for t, tunnel in vpn.tunnels :
        {
          create                          = coalesce(tunnel.create, vpn.create, local.create)
          project_id                      = coalesce(vpn.project_id, var.project, local.project)
          region                          = coalesce(vpn.region, local.region)
          router                          = coalesce(vpn.router, local.router)
          cloud_vpn_gateway               = vpn.cloud_vpn_gateway
          peer_gcp_vpn_gateway            = vpn.peer_gcp_vpn_gateway
          peer_external_gateway           = google_compute_external_vpn_gateway.default[vpn.peer_vpn_gateway].name
          name                            = tunnel.name
          description                     = tunnel.description
          ip_range                        = tunnel.ip_range
          ike_version                     = coalesce(vpn.ike_version, 2)
          vpn_gateway                     = local.cloud_vpn_gateway
          vpn_gateway_interface           = coalesce(tunnel.interface_index, t % 2 == 0 ? 0 : 1)
          peer_external_gateway_interface = coalesce(lookup(tunnel, "peer_interface_index", null), t)
          advertised_prefixes             = vpn.advertised_prefixes
          advertised_ip_ranges            = try(coalesce(tunnel.advertised_ip_ranges, vpn.advertised_ip_ranges), null)
          advertised_groups               = try(coalesce(tunnel.advertised_groups, vpn.advertised_groups), null)
          advertised_priority             = try(coalesce(tunnel.advertised_priority, vpn.advertised_priority), null)
          peer_bgp_name                   = tunnel.peer_bgp_name
          cloud_router_ip                 = tunnel.cloud_router_ip
          peer_bgp_ip                     = tunnel.peer_bgp_ip
          peer_bgp_asn = coalesce(
            tunnel.peer_bgp_asn,
            vpn.peer_bgp_asn,
            contains(keys(local.peer_vpn_gateways), vpn.peer_vpn_gateway) ? local.peer_vpn_gateways[vpn.peer_vpn_gateway].bgp_asn : null,
            var.peer_bgp_asn
          )
          enable         = coalesce(tunnel.enable, true)
          enable_ipv6    = coalesce(tunnel.enable, false)
          enable_bfd     = try(coalesce(tunnel.enable_bfd, vpn.enable_bfd), null)
          bfd_multiplier = vpn.bfd_multiplier
          vpn_name       = vpn.name
          tunnel_name    = tunnel.name
          interface_name = tunnel.interface_name
          vpn_key        = vpn_key
          tunnel_index   = t
          shared_secret  = tunnel.shared_secret
        }
      ]
    ]
  )
}

# Generate a null resource for each VPN tunnel, so n existing tunnel is completely destroyed before attempting re-create
# https://github.com/hashicorp/terraform-provider-google/issues/16619
resource "null_resource" "vpn_tunnels" {
  for_each = { for i, v in local.vpn_tunnels : "${v.region}/${v.name}" => true if v.create }
}
resource "google_compute_vpn_tunnel" "default" {
  for_each                        = { for i, v in local.vpn_tunnels : "${v.region}/${v.name}" => v if v.create }
  project                         = local.project
  region                          = each.value.region
  name                            = each.value.name
  description                     = each.value.description
  router                          = each.value.router
  peer_ip                         = null # only used in Classic VPN
  vpn_gateway                     = each.value.vpn_gateway
  peer_external_gateway           = google_compute_external_vpn_gateway.default[each.value.peer_external_gateway].self_link
  peer_gcp_gateway                = null
  ike_version                     = each.value.ike_version
  shared_secret                   = each.value.shared_secret
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  depends_on                      = [null_resource.vpn_tunnels]
  timeouts {
    create = null
    delete = null
    update = null
  }
}

locals {
  router_peers = { for i, v in local.vpn_tunnels :
    "${v.region}/${v.name}" => {
      create                        = v.create
      name                          = v.name
      region                        = v.region
      router                        = v.router
      interface_name                = coalesce(v.interface_name, "if-${v.name}")
      interface_ip_range            = "${cidrhost(v.ip_range, 1)}/30"
      vpn_tunnel_key                = "${v.region}/${v.name}"
      cloud_router_ip               = coalesce(v.cloud_router_ip, cidrhost(v.ip_range, 1)) # BGP peer uses the 1st IP in the /30
      peer_ip_address               = coalesce(v.peer_bgp_ip, cidrhost(v.ip_range, 2))     # BGP peer uses the 2nd IP in the /30
      peer_bgp_asn                  = v.peer_bgp_asn
      enable                        = true
      enable_ipv4                   = true
      enable_ipv6                   = false
      advertised_prefixes           = v.advertised_prefixes
      advertised_route_priority     = 100
      custom_learned_route_priority = 0
    }
  }
}

module "router-peers" {
  source                        = "../modules/router-peer"
  for_each                      = { for k, v in local.router_peers : k => v if v.create }
  project                       = local.project
  name                          = each.value.name
  region                        = each.value.region
  router                        = each.value.router
  interface_name                = each.value.interface_name
  interface_ip_range            = each.value.interface_ip_range
  vpn_tunnel                    = google_compute_vpn_tunnel.default[each.value.vpn_tunnel_key].name
  advertised_ip_ranges          = [for _ in each.value.advertised_prefixes : { range = _ }]
  advertised_route_priority     = each.value.advertised_route_priority
  custom_learned_route_priority = each.value.custom_learned_route_priority
  enable                        = each.value.enable
  enable_ipv4                   = each.value.enable_ipv4
  enable_ipv6                   = each.value.enable_ipv6
  cloud_router_ip               = each.value.cloud_router_ip
  peer_ip_address               = each.value.peer_ip_address
  peer_bgp_asn                  = each.value.peer_bgp_asn
}

