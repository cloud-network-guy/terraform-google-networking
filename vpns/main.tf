
# If IP Range for tunnel interfaces not provided, select a random one (169.254.2.0/28 - 169.254.253.240/28)
resource "random_integer" "tunnel_range" {
  count = var.tunnel_range == null ? 1 : 0
  min   = 64
  max   = 8160
}

# Create locals to pass to child module
locals {
  tunnel_range_prefix_length = var.tunnel_range != null ? split("/", var.tunnel_range)[1] : 29
  tunnel_range               = coalesce(var.tunnel_range, cidrsubnet("169.254.0.0/16", local.tunnel_range_prefix_length - 16, try(one(random_integer.tunnel_range).result, 0)))
  peer_vpn_gateway = {
    name           = var.peer_set.name
    description    = var.peer_set.description
    names          = [for i, peer in var.peer_set.peers : peer.name]
    ip_addresses   = [for i, peer in var.peer_set.peers : peer.ip_address]
    shared_secrets = [for i, peer in var.peer_set.peers : peer.shared_secret]
  }
  vpn = {
    region               = var.region
    cloud_router         = coalesce(var.cloud_router, "${var.network}-${var.region}")
    network              = var.network
    cloud_vpn_gateway    = coalesce(var.cloud_vpn_gateway, "${var.network}-${var.region}")
    advertised_ip_ranges = [for i, v in var.peer_set.advertised_ip_ranges : { range = v }]
    peer_vpn_gateway     = local.peer_vpn_gateway.name
    peer_bgp_asn         = var.peer_set.bgp_asn
    tunnels = [for i, peer in var.peer_set.peers :
      {
        name                = peer.name
        description         = peer.description
        ike_psk             = peer.shared_secret
        cloud_router_ip     = coalesce(peer.cloud_router_ip, "${split("/", cidrsubnet(local.tunnel_range, (32 - local.tunnel_range_prefix_length), i * 4 + 1))[0]}/30")
        peer_bgp_ip         = coalesce(peer.peer_bgp_ip, split("/", cidrsubnet(local.tunnel_range, (32 - local.tunnel_range_prefix_length), i * 4 + 2))[0])
        peer_bgp_name       = peer.name
        advertised_priority = coalesce(peer.advertised_priority, var.peer_set.advertised_priority)
        interface_index     = coalesce(peer.interface_index, i)
      }
    ]
  }
}

# If shared secret has not been set, create a random 32 character one to use
resource "random_string" "shared_secrets" {
  for_each = { for i, tunnel in local.vpn.tunnels : tunnel.name => true if tunnel.ike_psk == null }
  length   = 32
  special  = false
}

moved {
  from = module.hybrid-networking
  to   = module.vpns
}

# Call Child Module
module "vpns" {
  source     = "../modules/hybrid-networking"
  project_id = var.project_id
  region     = var.region
  peer_vpn_gateways = [
    {
      name         = local.peer_vpn_gateway.name
      description  = local.peer_vpn_gateway.description
      ip_addresses = local.peer_vpn_gateway.ip_addresses
    }
  ]
  vpns = [
    {
      region               = local.vpn.region
      cloud_router         = local.vpn.cloud_router
      cloud_vpn_gateway    = local.vpn.cloud_vpn_gateway
      peer_vpn_gateway     = local.vpn.peer_vpn_gateway
      peer_bgp_asn         = local.vpn.peer_bgp_asn
      advertised_ip_ranges = local.vpn.advertised_ip_ranges
      tunnels = [for i, tunnel in local.vpn.tunnels :
        merge(tunnel, {
          ike_psk = coalesce(try(random_string.shared_secrets[tunnel.name].result, null), tunnel.ike_psk, "")
        })
      ]
    }
  ]
}

# Lookup information from relevant cloud peer
data "google_compute_router" "cloud_router" {
  project = var.project_id
  network = var.network
  region  = local.vpn.region
  name    = local.vpn.cloud_router
}
