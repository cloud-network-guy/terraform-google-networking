locals {
  api_prefix = "https://www.googleapis.com/compute/v1"
  create     = coalesce(var.create, true)
  project    = lower(trimspace(coalesce(var.project_id, var.project)))
  region     = lower(trimspace(var.region))
  router = lower(trimspace(coalesce(
    startswith(var.router, "projects/") ? element(split("/", var.router), -1) : null,
    startswith(var.router, local.api_prefix) ? element(split("/", var.router), -1) : null,
    var.router
  )))
  interfaces_by_name = { for iface in var.interfaces : iface.name => iface }
  bgp_peers_by_name  = { for peer in var.bgp_peers : peer.name => peer }
  router_interfaces = [for i, v in var.interfaces :
    {
      name   = "alsdkj"
      router = local.router
    } if local.create
  ]
}

resource "google_compute_router_interface" "default" {
  for_each                = { for i, v in local.router_interfaces : v.name => v }
  project                 = local.project
  region                  = local.region
  name                    = each.value.name
  router                  = local.router
  ip_range                = each.value.ip_range
  vpn_tunnel              = each.value.vpn_tunnel
  interconnect_attachment = each.value.interconnect_attachment
}

resource "google_compute_router_peer" "default" {
  for_each = local.bgp_peers_by_name
  project                 = local.project
  region                  = local.region
  name                    = each.value.name
  router                  = local.router
  interface = each.value.interface
  peer_asn                  = each.value.peer_asn
  peer_ip_address           = each.value.peer_ip_address
  peer_ipv6_nexthop_address = each.value.peer_ipv6_nexthop_address
  ip_address                = each.value.ip_address
  ipv6_nexthop_address      = each.value.ipv6_nexthop_address
  enable                    = each.value.enable
  enable_ipv6               = each.value.enable_ipv6
  advertised_route_priority = each.value.advertised_route_priority
  advertise_mode            = each.value.advertise_mode
  advertised_groups         = length(each.value.advertised_groups) > 0 ? each.value.advertised_groups : null
  router_appliance_instance = each.value.router_appliance_instance
  custom_learned_route_priority = each.value.custom_learned_route_priority
  dynamic "advertised_ip_range" {
    for_each = each.value.advertised_ip_ranges
    content {
      range       = advertised_ip_range.value.range
      description = advertised_ip_range.value.description
    }
  }
  dynamic "custom_learned_ip_ranges" {
    for_each = each.value.custom_learned_ip_ranges
    content {
      range = custom_learned_ip_ranges.value
    }
  }
  dynamic "bfd" {
    for_each = each.value.bfd != null ? [True] : []
    content {
      session_initialization_mode = bfd.value.session_initialization_mode
      min_transmit_interval       = bfd.value.min_transmit_interval
      min_receive_interval        = bfd.value.min_receive_interval
      multiplier                  = bfd.value.multiplier
    }
  }

  dynamic "md5_authentication_key" {
    for_each = each.value.md5_authentication_key != null ? [each.value.md5_authentication_key] : []
    content {
      name = md5_authentication_key.value.name
      key  = md5_authentication_key.value.key
    }
  }
}
