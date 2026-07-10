output "regions" {
  value = local.regions
}
output "cloud_vpn_gateways" {
  value = { for k, v in local.regions :
    k => {
      name         = google_compute_ha_vpn_gateway.default[v.region].name
      ip_addresses = google_compute_ha_vpn_gateway.default[v.region].vpn_interfaces.*.ip_address
    } if local.create_cloud_vpn_gateways
  }
}
output "peer_vpn_gateways" {
  value = local.peer_vpn_gateways
}
output "vpn_tunnels" {
  value = local.vpn_tunnels
}
output "router_interfaces" {
  value = local.router_interfaces
}
output "router_peers" {
  value = local.router_peers
}
output "tunnel_ranges" {
  value = { for i, v in local.vpns : i => random_integer.tunnel_ranges["${v.region}/${v.name}"].result }
}