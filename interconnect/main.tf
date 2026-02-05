locals {
  create       = coalesce(var.create, true)
  project      = lower(trimspace(coalesce(var.project_id, var.project)))
  region       = lower(trimspace(var.region))
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  type         = upper(trimspace(var.type))
  mtu          = var.mtu
  router       = lower(trimspace(var.router))
}

# Interconnect Attachments
locals {
  interconnect_attachments = [for i, v in var.attachments :
    {
      create                    = coalesce(v.create, local.create)
      peer_is_gcp               = false
      name                      = coalesce(v.name, "attachment-${i}")
      description               = v.description
      interconnect              = null
      interface_name            = v.interface_name
      ipsec_internal_addresses  = coalesce(v.ipsec_internal_addresses, [])
      peer_asn                  = coalesce(v.peer_asn, var.peer_asn)
      advertised_ip_ranges      = coalesce(v.advertised_ip_ranges, var.advertised_ip_ranges)
      advertised_groups         = []
      advertised_route_priority = coalesce(v.advertised_route_priority, var.advertised_route_priority)
      ip_range                  = v.ip_range
      peer_ip_address           = null
      peer_name                 = v.peer_name
      mtu                       = coalesce(v.mtu, local.mtu)
      admin_enabled             = true # TODO
      encryption                = upper(trimspace(var.encryption))
      enable_bfd                = coalesce(v.bfd, var.bfd)
      enable_ipv4               = coalesce(v.enable_ipv4, var.enable_ipv4)
      enable_ipv6               = coalesce(v.enable_ipv6, var.enable_ipv6)
      stack_type                = "IPV4_ONLY" # TODO
    }
  ]
}
resource "google_compute_interconnect_attachment" "default" {
  for_each                 = { for i, v in local.interconnect_attachments : v.name => v }
  project                  = local.project
  name                     = each.value.name
  description              = each.value.description
  region                   = local.region
  router                   = local.router
  ipsec_internal_addresses = each.value.ipsec_internal_addresses
  encryption               = each.value.encryption
  mtu                      = each.value.mtu
  admin_enabled            = each.value.admin_enabled
  type                     = local.type
  interconnect             = each.value.interconnect
  stack_type               = each.value.stack_type
  timeouts {
    create = null
    delete = null
    update = null
  }
}

# Router Interfaces
locals {
  router_interfaces = [for i, v in local.interconnect_attachments :
    {
      create                  = v.create
      name                    = lower(trimspace(coalesce(v.interface_name, "if-${v.name}")))
      interconnect_attachment = google_compute_interconnect_attachment.default[v.name].self_link
      ip_range                = v.ip_range
      ip_version              = null # TODO
      private_ip_address      = null # TODO
      redundant_interface     = null # TODO
      subnetwork              = null # TODO
    } if v.create
  ]
}
resource "google_compute_router_interface" "default" {
  for_each                = { for i, v in local.router_interfaces : i => v }
  interconnect_attachment = each.value.interconnect_attachment
  ip_range                = each.value.ip_range
  ip_version              = each.value.ip_version
  name                    = each.value.name
  private_ip_address      = each.value.private_ip_address
  project                 = local.project
  redundant_interface     = each.value.redundant_interface
  region                  = local.region
  router                  = local.router
  subnetwork              = each.value.subnetwork
  vpn_tunnel              = null
  timeouts {

  }
}

# Router BGP Peers
locals {
  router_peers = [for i, v in local.interconnect_attachments :
    {
      create                        = v.create
      enable                        = true
      name                          = v.peer_name
      ip_address                    = null
      peer_ip_address               = v.peer_ip_address
      peer_asn                      = v.peer_asn
      advertise_mode                = length(v.advertised_ip_ranges) > 0 ? "CUSTOM" : "DEFAULT"
      advertised_groups             = v.advertised_groups
      advertised_route_priority     = v.advertised_route_priority
      custom_learned_route_priority = 0 # TODO
      enable_ipv4                   = v.enable_ipv4
      enable_ipv6                   = v.enable_ipv6
      export_policies               = [] # TODO
      import_policies               = [] # TODO
      interface                     = google_compute_router_interface.default[i].name
      ipv4_nexthop_address          = null # TODO
      ipv6_nexthop_address          = null # TODO
      peer_ipv4_nexthop_address     = null # TODO
      peer_ipv6_nexthop_address     = null # TODO
      router_appliance_instance     = null # TODO
      bfd = {
        session_initialization_mode = v.enable_bfd ? "ACTIVE" : "DISABLED"
        min_transmit_interval       = 1000 # TODO
        min_receive_interval        = 1000 # TODO
        multiplier                  = 5    # TODO
      }
    } if v.create
  ]
}
resource "google_compute_router_peer" "default" {
  for_each                      = { for i, v in local.router_peers : i => v }
  advertise_mode                = each.value.advertise_mode
  advertised_groups             = each.value.advertised_groups
  advertised_route_priority     = each.value.advertised_route_priority
  custom_learned_route_priority = each.value.custom_learned_route_priority
  enable                        = each.value.enable
  enable_ipv4                   = each.value.enable_ipv4
  enable_ipv6                   = each.value.enable_ipv6
  export_policies               = each.value.export_policies
  import_policies               = each.value.import_policies
  interface                     = each.value.interface
  ip_address                    = each.value.ip_address
  ipv4_nexthop_address          = each.value.ipv4_nexthop_address
  ipv6_nexthop_address          = each.value.ipv6_nexthop_address
  name                          = each.value.name
  peer_asn                      = each.value.peer_asn
  peer_ip_address               = each.value.peer_ip_address
  peer_ipv4_nexthop_address     = each.value.peer_ipv4_nexthop_address
  peer_ipv6_nexthop_address     = each.value.peer_ipv6_nexthop_address
  project                       = local.project
  region                        = local.region
  router                        = local.router
  router_appliance_instance     = each.value.router_appliance_instance
  bfd {
    min_receive_interval        = each.value.bfd.min_receive_interval
    min_transmit_interval       = each.value.bfd.min_transmit_interval
    multiplier                  = each.value.bfd.multiplier
    session_initialization_mode = each.value.bfd.session_initialization_mode
  }
  timeouts {

  }
}
