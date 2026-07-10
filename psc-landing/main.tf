locals {
  create                       = coalesce(var.create, true)
  environment                  = lower(trimspace(var.environment))
  project                      = lower(trimspace(var.project))
  vpc_network_name             = "${local.project}-dmz-vpc"
  network_project              = lower(trimspace(var.network_project))
  psc_consumer_subnetwork_name = lower(trimspace(var.psc_consumer_subnetwork_name))
  proxy_only_subnetwork_name   = lower(trimspace(var.proxy_only_subnetwork_name))
  regions = { for k, v in var.regions :
    k => merge(v, {
      region               = lower(trimspace(k))
      bgp_asn              = coalesce(v.cloud_router_bgp_asn, var.cloud_router_bgp_asn)
      psc_consumers        = coalesce(v.psc_consumers, [])
      vpns                 = coalesce(v.vpns, [])
      interconnects        = coalesce(v.interconnects, [])
      advertised_ip_ranges = coalesce(v.advertised_ip_ranges, [])
    })
  }
  global_routing = length(local.regions) > 1 ? true : false
  create_cloud_vpn_gateways = coalesce(
    var.create_cloud_vpn_gateways,
    anytrue([for region in local.regions : length(region.vpns) > 0 ? true : false]),
  )
  vpn_ike_version = 2
  vpn_tunnel_cidr = "169.254.0.0/16"
}

locals {
  peerings = var.create_peering_to_network_project ? [
    {
      name                 = "${local.environment}-dmz-vpc"
      peer_project         = local.network_project
      peer_network         = "${local.environment}-dmz-vpc"
      import_custom_routes = true
      export_custom_routes = true
    },
  ] : []
  firewall_rules = [
    {
      name          = "dmz-internal-ingress"
      description   = "Permit all traffic from internal IP address ranges"
      direction     = "ingress"
      priority      = 999
      source_ranges = var.internal_ip_addresses
      allow = [
        { protocol : "tcp", ports : ["1-65535"] },
        { protocol : "udp", ports : ["1-65535"] },
        { protocol : "icmp" },
      ]
      logging = true
    },
    {
      name        = "dmz-iap-ingress"
      description = "Permit SSH & RDP via IAP"
      direction   = "ingress"
      priority    = 999
      range_type  = "iap-forwarders"
      protocol    = "tcp"
      ports       = [22, 3398]
      logging     = true
    },
    {
      name               = "dmz-internal-egress"
      description        = "Permit all traffic from internal IP address ranges"
      direction          = "egress"
      priority           = 999
      destination_ranges = var.internal_ip_addresses
      allow = [
        { protocol : "tcp", ports : ["1-65535"] },
        { protocol : "udp", ports : ["1-65535"] },
        { protocol : "icmp" },
      ]
      logging = true
    },
  ]
  cloud_routers = [for k, v in local.regions :
    {
      region  = v.region
      name    = "${local.vpc_network_name}-${v.region}"
      bgp_asn = v.bgp_asn
    }
  ]
  subnets = concat(
    [for k, v in local.regions :
      {
        region         = v.region
        name           = "${local.psc_consumer_subnetwork_name}"
        description    = "PSC Consumer Endpoints"
        ip_range       = v.psc_consumers_cidr
        purpose        = "PRIVATE"
        private_access = false
      } if v.psc_consumers_cidr != null
    ],
    # Proxy-only subnet
    [for k, v in local.regions :
      {
        region         = v.region
        name           = "${v.region}-${local.proxy_only_subnetwork_name}"
        description    = "Proxy only subnet for regional load balancer"
        ip_range       = v.proxy_only_cidr
        purpose        = "REGIONAL_MANAGED_PROXY"
        private_access = false
      } if v.proxy_only_cidr != null
    ]
  )
}

# Create VPC network and related resources
module "vpc-network" {
  source                  = "../modules/vpc-network"
  project                 = local.project
  create                  = local.create
  name                    = local.vpc_network_name
  description             = null
  mtu                     = 1460
  auto_create_subnetworks = false
  global_routing          = local.global_routing
  subnets                 = local.subnets
  peerings                = local.peerings
  firewall_rules          = local.firewall_rules
  cloud_routers           = local.cloud_routers
}

# Create and associate DNS policy for inbound querying listeners & logging
module "dns-policy" {
  source                    = "../modules/dns-policy"
  project_id                = local.project
  create                    = local.create
  name                      = "${local.vpc_network_name}-dns-policy"
  description               = "DNS policy for landing DMZ VPC network"
  logging                   = true
  enable_inbound_forwarding = true
  networks                  = [module.vpc-network.id]
}

# DNS Zones & Records

locals {
  dns_zones = { for k, v in var.dns_zones :
    k => merge(v, {
      name = lower(trimspace(coalesce(v.name, k)))
      #project_id      = lower(trimspace(coalesce(v.project_id, local.project)))
      #host_project_id = lower(trimspace(coalesce(v.host_project_id, v.host_project, local.host_project_id)))
    })
  }
}
resource "null_resource" "dns_zone" {
  for_each = { for k, v in local.dns_zones : k => v }
}
module "dns-zone" {
  source              = "../modules/dns-zone"
  for_each            = { for k, v in local.dns_zones : k => v if local.create }
  project_id          = local.project
  host_project_id     = each.value.host_project_id
  create              = each.value.create
  name                = each.value.name
  description         = each.value.description
  dns_name            = each.value.dns_name
  visibility          = each.value.visibility
  peer_project        = each.value.peer_project
  peer_network        = each.value.peer_network
  target_name_servers = each.value.target_name_servers
  networks            = each.value.networks
  records             = each.value.records
  depends_on          = [null_resource.dns_zone]
}


# Build PSC Consumer Endpoints
locals {
  _psc_consumers = flatten([for k, v in local.regions :
    [for psc_endpoint in v.psc_consumers :
      {
        create         = psc_endpoint.create
        region         = k
        target_service = lower(trimspace(psc_endpoint.target_service))
        name           = psc_endpoint.name
        description    = psc_endpoint.description
        nat_subnets    = ["projects/${local.network_project}/regions/${k}/subnetworks/${psc_endpoint.nat_subnet}"]
      }
    ]
  ])
  psc_consumers = [for i, v in local._psc_consumers :
    merge(v, {
      name           = coalesce(v.name, v.target_service)
      target_service = "projects/${local.project}/regions/${v.region}/forwardingRules/${v.target_service}"
    })
  ]
}
# Publish ILBs via PSC and share to the local project
resource "google_compute_service_attachment" "default" {
  for_each              = { for i, v in local.psc_consumers : "${v.region}/${v.name}" => v if v.create }
  project               = local.project
  region                = each.value.region
  name                  = each.value.name
  description           = each.value.description
  nat_subnets           = each.value.nat_subnets
  target_service        = each.value.target_service
  enable_proxy_protocol = false
  connection_preference = "ACCEPT_MANUAL"
  consumer_accept_lists {
    project_id_or_num = local.project # Allow our own project to connect
    connection_limit  = 2             # Allow at least two connections
  }
  consumer_reject_lists = []
  domain_names          = []
  reconcile_connections = true
}

# Create PSC Consumer endpoints
module "psc-consumers" {
  source              = "../modules/forwarding-rule"
  for_each            = { for k, v in local.psc_consumers : "${v.region}/${v.name}" => v if v.create }
  create              = each.value.create
  project             = local.project
  region              = each.value.region
  name                = "${each.value.name}-psc"
  address_name        = "${each.value.name}-psc"
  address_description = ""
  description         = "PSC consumer endpoint to '${each.value.name}'"
  #target = google_compute_service_attachment.default["${each.value.region}/${each.value.name}"].id
  target  = "projects/${local.project}/regions/${each.value.region}/serviceAttachments/${each.value.name}"
  network = module.vpc-network.id
  subnetwork = one(
    [for subnet in module.vpc-network.subnets :
      subnet.id if subnet.region == each.value.region && subnet.name == local.psc_consumer_subnetwork_name
    ]
  )
  set_null_subnetwork = var.set_null_subnetwork_for_psc_consumers
  global_access       = false
  depends_on          = [module.vpc-network, google_compute_service_attachment.default]
}



# Create Interconnect related resources

# Create a VPN Gateway in each Region
resource "google_compute_ha_vpn_gateway" "default" {
  for_each   = { for k, v in local.regions : k => v if local.create_cloud_vpn_gateways }
  project    = local.project
  name       = "${local.vpc_network_name}-${each.key}"
  network    = module.vpc-network.name
  region     = each.value.region
  stack_type = "IPV4_ONLY"
}

locals {
  peer_vpn_gateways = { for k, v in var.peer_vpn_gateways :
    k => {
      create      = v.create
      name        = k
      description = v.description
      interfaces = [for i, interface in v.interfaces :
        {
          id          = i
          ip_address  = trimspace(interface.ip_address)
          description = coalesce(interface.description, "interface ${i}")
          bgp_asn     = coalesce(interface.bgp_asn, v.bgp_asn, var.peer_bgp_asn)
        }
      ]
      redundancy_type = length(v.interfaces) >= 2 ? "TWO_IPS_REDUNDANCY" : "SINGLE_IP_INTERNALLY_REDUNDANT"
    } if v.create
  }
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
  vpns = flatten([for k, v in local.regions :
    [for vpn in v.vpns :
      {
        create      = vpn.create
        name        = vpn.name
        description = vpn.description
        region      = v.region
        router = one([for router in module.vpc-network.cloud_routers :
          router.name if router.name == "${local.vpc_network_name}-${v.region}"
        ])
        vpn_gateway = google_compute_ha_vpn_gateway.default[v.region].name
        #peer_external_gateway = contains(keys(local.peer_vpn_gateways), vpn.peer_vpn_gateway) ? google_compute_external_vpn_gateway.default[vpn.peer_vpn_gateway].name : null
        peer_external_gateway = lookup(local.peer_vpn_gateways, vpn.peer_vpn_gateway, null)
        #ike_psk               = vpn.ike_psk
        tunnel_ip_ranges                   = vpn.tunnel_ip_ranges
        tunnel_advertised_route_priorities = lookup(vpn, "tunnel_advertised_route_priorities", null)
        tunnel_ike_psk                     = lookup(vpn, "tunnel_ike_psk", null)
        custom_learned_route_priority      = lookup(vpn, "custom_learned_route_priority", 100)
      }
    ]
  ])
}
# Generate a base number to be used to allocate a /28 for each tunnel set
# 169.254.0.0/16 / /28 = 2^14
resource "random_integer" "tunnel_ranges" {
  for_each = { for i, v in local.vpns : "${v.region}/${v.name}" => true }
  min      = 32   # don't use 169.254.[0-1].X
  max      = 4064 # don't use 169.254.[254-255].X
}
locals {
  _vpn_tunnels = flatten([for vpn in local.vpns :
    [for i, interface in vpn.peer_external_gateway.interfaces :
      {
        create                          = vpn.create
        index                           = i
        vpn_gateway_interface           = i
        name                            = "${vpn.name}-${i}"
        vpn_name                        = vpn.name
        description                     = coalesce(interface.description, vpn.description, "VPN Tunnel ${i}")
        region                          = vpn.region
        router                          = vpn.router
        vpn_gateway                     = vpn.vpn_gateway
        peer_external_gateway           = vpn.peer_external_gateway != null ? google_compute_external_vpn_gateway.default[vpn.peer_external_gateway.name].name : null
        peer_external_gateway_interface = i
        shared_secret                   = (vpn.tunnel_ike_psk != null ? vpn.tunnel_ike_psk[i] : null)
        peer_asn                        = interface.bgp_asn
        ip_range                        = vpn.tunnel_ip_ranges[i]
        advertised_route_priority       = vpn.tunnel_advertised_route_priorities != null ? vpn.tunnel_advertised_route_priorities[i] : null
      }
    ]
  ])
}

# Generate a random PSK for each tunnel
resource "random_string" "ike_psks" {
  for_each = { for i, v in local._vpn_tunnels : "${v.region}/${v.name}" => true }
  length   = var.vpn_ike_psk_length
  special  = false
}

# Create actual VPN Tunnels
locals {
  vpn_tunnels = [for i, v in local._vpn_tunnels :
    merge(v, {
      is_vpn          = true
      is_interconnect = false
      shared_secret   = coalesce(v.shared_secret, random_string.ike_psks["${v.region}/${v.name}"].result)
    })
  ]
}
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
  peer_external_gateway           = each.value.peer_external_gateway
  peer_gcp_gateway                = null
  ike_version                     = local.vpn_ike_version
  shared_secret                   = each.value.shared_secret
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  depends_on                      = [null_resource.vpn_tunnels]
}

locals {
  interconnects = flatten([for k, v in local.regions :
    [for i, interconnect in v.interconnects :
      merge(interconnect, {
        region = v.region
        router = one([for router in module.vpc-network.cloud_routers :
          router.name if router.name == "${local.vpc_network_name}-${v.region}"
        ])
        advertised_route_priority = coalesce(interconnect.advertised_route_priority, 0)
        mtu                       = coalesce(interconnect.mtu, var.interconnect_mtu)
        peer_names                = coalesce(interconnect.peer_names, [])
        interface_names           = coalesce(interconnect.interface_names, [])
        ip_ranges                 = coalesce(interconnect.ip_ranges, [])
        peer_asn                  = coalesce(interconnect.peer_bgp_asn, var.peer_bgp_asn)
      })
    ]
  ])
  interconnect_attachments = flatten([for interconnect in local.interconnects :
    [for attachment_index, attachment in range(0, length(interconnect.peer_names)) :
      {
        is_interconnect           = true
        is_vpn                    = false
        index                     = attachment_index
        create                    = interconnect.create
        name                      = coalesce(interconnect.attachment_names[attachment_index], "attachment-${attachment_index}")
        region                    = interconnect.region
        router                    = interconnect.router
        description               = interconnect.description
        mtu                       = interconnect.mtu
        interconnect              = null
        ipsec_internal_addresses  = []
        peer_asn                  = interconnect.peer_asn
        advertised_groups         = []
        advertised_route_priority = interconnect.advertised_route_priority
        peer_ip_address           = null
        interface_name            = interconnect.interface_names[attachment_index]
        ip_range                  = interconnect.ip_ranges[attachment_index]
        peer_name                 = interconnect.peer_names[attachment_index]
        stack_type                = "IPV4_ONLY" #TODO
        type                      = "PARTNER"   # TODO
        admin_enabled             = true        # TODO
        encryption                = "NONE"      # TODO
      }
    ]
  ])
}
# Interconnect Attachments
resource "google_compute_interconnect_attachment" "default" {
  for_each                 = { for i, v in local.interconnect_attachments : "${v.region}/${v.name}" => v if v.create }
  project                  = local.project
  region                   = each.value.region
  name                     = each.value.name
  router                   = each.value.router
  mtu                      = each.value.mtu
  ipsec_internal_addresses = each.value.ipsec_internal_addresses
  encryption               = each.value.encryption
  admin_enabled            = each.value.admin_enabled
  type                     = each.value.type
  interconnect             = each.value.interconnect
  stack_type               = each.value.stack_type
  timeouts {
    create = null
    delete = null
    update = null
  }
}

# Cloud Router Interfaces
locals {
  _router_interfaces = [for i, v in concat(local.vpn_tunnels, local.interconnect_attachments) :
    {
      create                    = v.create
      is_vpn                    = v.is_vpn
      is_interconnect           = v.is_interconnect
      index                     = v.index
      attachment_name           = v.is_interconnect ? v.name : null
      name                      = v.is_interconnect ? v.interface_name : v.name
      region                    = v.region
      router                    = v.router
      peer_external_gateway     = v.is_vpn ? v.peer_external_gateway : null
      vpn_name                  = v.is_vpn ? v.vpn_name : null
      peer_name                 = v.is_interconnect ? v.peer_name : null
      peer_asn                  = v.peer_asn
      ip_range                  = v.ip_range
      advertised_ip_ranges      = local.regions[v.region].advertised_ip_ranges
      advertised_route_priority = v.advertised_route_priority
    }
  ]
}

locals {
  router_interfaces = [for i, v in local._router_interfaces :
    merge(v, {
      redundant_interface     = null   # TODO
      ip_version              = "IPV4" # TODO
      vpn_tunnel              = v.is_vpn ? google_compute_vpn_tunnel.default["${v.region}/${v.name}"].name : null
      interconnect_attachment = v.is_interconnect ? google_compute_interconnect_attachment.default["${v.region}/${v.attachment_name}"].self_link : null
      advertised_ip_ranges = coalescelist(
        v.advertised_ip_ranges,
        [for subnet in module.vpc-network.subnets : { range = subnet.ip_range, description = null }
          if subnet.region == v.region && subnet.purpose == "PRIVATE"
        ]
      )
      # Give each interface a /30
      ip_range = coalesce(
        v.ip_range,
        # Use auto-generated CIDR base number to define tunnel IP ranges
        v.is_vpn ? cidrsubnet(
          local.vpn_tunnel_cidr,
          14, # 30 - 16 = 14, so we need to move 14 bits
          (4 * random_integer.tunnel_ranges["${v.region}/${v.vpn_name}"].result) + v.index
        ) : null
      )
    }) if v.create
  ]
}
# Work-around to force BGP peer re-creation when router IP addresses change
resource "null_resource" "router_ip_ranges" {
  for_each = { for i, v in local.router_interfaces : v.ip_range => true if v.create }
}
resource "google_compute_router_interface" "default" {
  for_each                = { for i, v in local.router_interfaces : "${v.region}/${v.name}" => v if v.create }
  project                 = local.project
  region                  = each.value.region
  name                    = each.value.name
  router                  = each.value.router
  ip_range                = each.value.is_vpn ? "${cidrhost(each.value.ip_range, 1)}/30" : each.value.ip_range
  vpn_tunnel              = each.value.is_vpn ? each.value.vpn_tunnel : null
  interconnect_attachment = each.value.is_interconnect ? each.value.interconnect_attachment : null
  redundant_interface     = each.value.redundant_interface
  ip_version              = each.value.ip_version
}

# BGP Peers
locals {
  router_peers = [for i, v in local.router_interfaces :
    {
      create                             = v.create
      name                               = v.is_vpn ? v.name : v.peer_name
      region                             = v.region
      router                             = v.router
      interface                          = google_compute_router_interface.default["${v.region}/${v.name}"].name
      peer_ip_address                    = cidrhost(v.ip_range, 2) # BGP peer uses the 2nd IP in the /30
      peer_asn                           = v.peer_asn
      advertised_route_priority          = v.advertised_route_priority
      custom_learned_route_priority      = v.is_vpn ? coalesce(local.vpns[index(local.vpns.*.name, v.vpn_name)].custom_learned_route_priority, 100) : null
      zero_custom_learned_route_priority = false # TODO
      advertised_ip_ranges               = v.advertised_ip_ranges
      advertised_groups                  = []
      advertise_mode                     = length(v.advertised_ip_ranges) > 0 ? "CUSTOM" : "DEFAULT"
    }
  ]
}
resource "google_compute_router_peer" "default" {
  for_each                           = { for i, v in local.router_peers : "${v.region}/${v.name}" => v if v.create }
  project                            = local.project
  region                             = each.value.region
  name                               = each.value.name
  router                             = each.value.router
  interface                          = each.value.interface
  peer_ip_address                    = each.value.peer_ip_address
  peer_asn                           = each.value.peer_asn
  custom_learned_route_priority      = each.value.custom_learned_route_priority
  zero_custom_learned_route_priority = each.value.zero_custom_learned_route_priority
  advertised_route_priority          = each.value.advertised_route_priority
  advertised_groups                  = each.value.advertised_groups
  advertise_mode                     = each.value.advertise_mode
  dynamic "advertised_ip_ranges" {
    for_each = each.value.advertised_ip_ranges
    content {
      range       = advertised_ip_ranges.value.range
      description = lookup(advertised_ip_ranges.value, "description", "")
    }
  }
  dynamic "bfd" {
    for_each = [true]
    content {
      min_receive_interval        = 1000
      min_transmit_interval       = 1000
      multiplier                  = 5
      session_initialization_mode = "DISABLED"
    }
  }
  enable      = true
  enable_ipv6 = false
  depends_on  = [google_compute_router_interface.default]
}

# Outbound PSC w/ Hybrid Negs