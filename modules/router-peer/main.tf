locals {
  api_prefix = "https://www.googleapis.com/compute/v1"
  create     = coalesce(var.create, true)
  project    = lower(trimspace(coalesce(var.project_id, var.project)))
  name       = lower(trimspace(var.name))
  region     = lower(trimspace(var.region))
  router = lower(trimspace(coalesce(
    startswith(var.router, "projects/") ? element(split("/", var.router), -1) : null,
    startswith(var.router, local.api_prefix) ? element(split("/", var.router), -1) : null,
    var.router
  )))
  is_vpn                        = var.vpn_tunnel != null ? true : false
  vpn_tunnel                    = local.is_vpn ? lower(trimspace(var.vpn_tunnel)) : null
  interconnect_attachment       = !local.is_vpn ? lower(trimspace(var.interconnect_attachment)) : null
  interface_name                = lower(trimspace(coalesce(var.interface_name, "lasdjf")))
  ip_range                      = var.interface_ip_range
  peer_asn                      = coalesce(var.peer_bgp_asn, local.is_vpn ? 65000 : null)
  enable                        = var.enable
  enable_ipv4                   = var.enable_ipv4
  enable_ipv6                   = var.enable_ipv6
  advertised_route_priority     = var.advertised_route_priority
  ip_address                    = var.cloud_router_ip
  peer_ip_address               = var.peer_ip_address
  advertise_mode                = coalesce(var.advertise_mode, length(var.advertised_ip_ranges) > 0 ? "CUSTOM" : "DEFAULT")
  peer_ipv6_nexthop_address     = null # TODO
  ipv6_nexthop_address          = null # TODO
  router_appliance_instance     = null # TODO
  custom_learned_route_priority = null # TODO
  advertised_ip_ranges          = var.advertised_ip_ranges
  custom_learned_ip_ranges      = []
  advertised_groups             = [] # TODO
  use_bfd                       = var.bfd != null ? true : false
  bfd = {
    session_initialization_mode = local.use_bfd ? lookup(var.bfd, "session_initialization_mode", null) : null
    min_transmit_interval       = local.use_bfd ? lookup(var.bfd, "min_transmit_interval", null) : null
    min_receive_interval        = local.use_bfd ? lookup(var.bfd, "min_receive_interval", null) : null
    multiplier                  = local.use_bfd ? lookup(var.bfd, "multiplier", null) : null
  }
  use_md5_authentication_key = var.md5_authentication_key != null ? true : false
  md5_authentication_key = {
    name = local.use_md5_authentication_key ? lookup(var.md5_authentication_key, "name", null) : null
    key  = local.use_md5_authentication_key ? lookup(var.md5_authentication_key, "key", null) : null
  }
}

resource "google_compute_router_interface" "default" {
  count                   = local.create ? 1 : 0
  project                 = local.project
  region                  = local.region
  name                    = local.interface_name
  router                  = local.router
  ip_range                = local.ip_range
  vpn_tunnel              = local.vpn_tunnel
  interconnect_attachment = local.interconnect_attachment
}

resource "google_compute_router_peer" "default" {
  count                         = local.create ? 1 : 0
  project                       = local.project
  region                        = local.region
  name                          = local.name
  router                        = local.router
  interface                     = local.create ? one(google_compute_router_interface.default).name : null
  peer_asn                      = local.peer_asn
  peer_ip_address               = local.peer_ip_address
  peer_ipv6_nexthop_address     = local.peer_ipv6_nexthop_address
  ip_address                    = local.ip_address
  ipv6_nexthop_address          = local.ipv6_nexthop_address
  enable                        = local.enable
  enable_ipv6                   = local.enable_ipv6
  advertised_route_priority     = local.advertised_route_priority
  advertise_mode                = local.advertise_mode
  advertised_groups             = length(local.advertised_groups) > 0 ? local.advertised_groups : null
  router_appliance_instance     = local.router_appliance_instance
  custom_learned_route_priority = local.custom_learned_route_priority
  dynamic "advertised_ip_ranges" {
    for_each = local.advertised_ip_ranges
    content {
      range       = advertised_ip_ranges.value.range
      description = advertised_ip_ranges.value.description
    }
  }
  dynamic "custom_learned_ip_ranges" {
    for_each = local.custom_learned_ip_ranges
    content {
      range = custom_learned_ip_ranges.value.range
    }
  }
  dynamic "bfd" {
    for_each = local.use_bfd ? [true] : []
    content {
      session_initialization_mode = local.bfd.session_initialization_mode
      min_transmit_interval       = local.bfd.min_transmit_interval
      min_receive_interval        = local.bfd.min_receive_interval
      multiplier                  = local.bfd.multiplier
    }
  }
  dynamic "md5_authentication_key" {
    for_each = local.use_md5_authentication_key ? [true] : []
    content {
      name = local.md5_authentication_key.name
      key  = local.md5_authentication_key.key
    }
  }
  timeouts {
    create = null
    delete = null
    update = null
  }
}
