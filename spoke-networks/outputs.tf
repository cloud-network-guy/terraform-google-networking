output "network_name" { value = module.vpc-network.name }
output "network_id" { value = module.vpc-network.id }
output "network_self_link" { value = module.vpc-network.self_link }
output "peering_connections" { value = module.vpc-network.peering_connections }
output "subnets" { value = module.vpc-network.subnets }
output "cloud_nats" { value = module.vpc-network.cloud_nats }
output "spoke_vpn_tunnels" {
  value = { for i, v in local.spoke_vpn_tunnels :
    v.index_key => {
      name                    = v.name
      cloud_router_ip_address = v.ip_range
      peer_ip_address         = v.peer_ip_address
      peer_gateway_ip         = try(google_compute_vpn_tunnel.default[v.index_key].peer_ip, null)
      cloud_vpn_gateway_ip    = try(google_compute_ha_vpn_gateway.default.vpn_interfaces.*.ip_address[v.tunnel_index], "unknown")
      detailed_status         = google_compute_vpn_tunnel.default[v.index_key].detailed_status
    }
  }
}
