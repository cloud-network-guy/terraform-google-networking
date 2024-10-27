output "project" { value = local.project }
output "name" { value = local.name }
output "id" { value = local.network }
output "network" { value = local.network }
output "self_link" { value = local.network_self_link }
output "subnets" {
  value = [
    for subnet in local.subnets :
    {
      name     = subnet.name
      region   = subnet.region
      ip_range = subnet.ip_range
      id       = try(google_compute_subnetwork.default["${subnet.region}/${subnet.name}"].id, null)
      purpose  = subnet.purpose
    }
  ]
}
output "peering_connections" {
  value = [for peering_connection in local.peerings :
    {
      peer_network  = google_compute_network_peering.default[peering_connection.name].peer_network
      state         = try(google_compute_network_peering.default[peering_connection.name].state, null)
      state_details = try(google_compute_network_peering.default[peering_connection.name].state_details, null)
    } if peering_connection.create
  ]
}
output "cloud_routers" {
  value = [for cloud_router in local.cloud_routers :
    {
      name    = google_compute_router.default["${cloud_router.region}/${cloud_router.name}"].name
      region  = google_compute_router.default["${cloud_router.region}/${cloud_router.name}"].region
      bgp_asn = cloud_router.enable_bgp ? one(google_compute_router.default["${cloud_router.region}/${cloud_router.name}"].bgp).asn : null
    } if cloud_router.create
  ]
}
output "cloud_nats" {
  value = [for cloud_nat in local.cloud_nats :
    {
      #name      = google_compute_address.cloud_nat["{}"]
      region = cloud_nat.region
      router = cloud_nat.router
      addresses = [for k, v in local.cloud_nat_addresses :
        google_compute_address.cloud_nat["${v.region}/${v.name}"].address
      ]
    } if cloud_nat.create
  ]
}
