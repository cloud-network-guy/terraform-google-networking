/*
output "vpns" {
  value = [for region, vpn in local.vpns : {
    region       = vpn.region
    cloud_router = vpn.router
    tunnels = {
      for i, tunnel in local.vpn_tunnels :
      tunnel.name => {
        name = tunnel.name
      }
    }
  }]
}
*/

output "vpn_tunnels" {
  value = [for i, v in local.vpn_tunnels :
    {
      name                    = v.name
      ike_version             = v.ike_version
      shared_secret           = v.shared_secret
      cloud_vpn_gateway_ip    = try(data.google_compute_ha_vpn_gateway.default["${v.region}/${v.vpn_gateway}"].vpn_interfaces.*.ip_address[v.tunnel_index], "unknown")
      peer_vpn_gateway_ip     = google_compute_vpn_tunnel.default["${v.region}/${v.name}"].peer_ip
      detailed_status         = google_compute_vpn_tunnel.default["${v.region}/${v.name}"].detailed_status
      cloud_router_ip_address = module.router-peers["${v.region}/${v.name}"].interface_ip_range
      peer_ip_address         = module.router-peers["${v.region}/${v.name}"].peer_ip_address
      peer_bgp_asn            = v.peer_bgp_asn
      cloud_router_bgp_asn    = try(data.google_compute_router.default["${v.region}/${v.router}"].bgp[0].asn, "ERROR")
    }
  ]
}
