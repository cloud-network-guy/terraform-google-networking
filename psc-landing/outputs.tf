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
  value = {
    for k, v in local.peer_vpn_gateways :
    k => {
      name        = google_compute_external_vpn_gateway.default[v.name].name
      description = google_compute_external_vpn_gateway.default[v.name].description
      interfaces = [
        for i, interface in v.interfaces :
        {
          bgp_asn     = interface.bgp_asn
          description = interface.description
          ip_address  = google_compute_external_vpn_gateway.default[v.name].interface[interface.id].ip_address
        }
      ]
    }
  }
}

output "vpn_tunnels" {
  value = [
    for i, v in local.vpn_tunnels :
    {
      vpn_name                  = v.vpn_name
      name                      = v.name
      description               = v.description
      region                    = v.region
      peer_external_gateway     = v.peer_external_gateway
      peer_interface_id         = v.peer_external_gateway_interface
      peer_asn                  = v.peer_asn
      cloud_vpn_gateway_ip      = google_compute_ha_vpn_gateway.default[v.region].vpn_interfaces.*.ip_address[v.index]
      ip_range                  = v.ip_range
      advertised_route_priority = v.advertised_route_priority
      shared_secret             = v.shared_secret
    } if v.create
  ]
}
output "router_interfaces" {
  value = [
    for i, v in local.router_interfaces :
    {
      name                    = v.name
      region                  = v.region
      router                  = v.router
      ip_range                = v.ip_range
      ip_version              = v.ip_version
      attachment_name         = v.attachment_name
      vpn_tunnel              = v.vpn_tunnel
      interconnect_attachment = v.interconnect_attachment
    } if v.create
  ]
}
output "router_peers" {
  value = [
    for i, v in local.router_peers :
    {
      advertise_mode            = v.advertise_mode
      advertised_ip_ranges      = v.advertised_ip_ranges
      advertised_route_priority = v.advertised_route_priority
      name                      = v.name
      interface_name            = v.interface_name
      peer_asn                  = v.peer_bgp_asn
      peer_ip_address           = v.peer_ip_address
      region                    = v.region
      router                    = v.router
    } if v.create
  ]
}
output "tunnel_ranges" {
  value = {
    for i, v in local.vpns :
    i => random_integer.tunnel_ranges["${v.region}/${v.name}"].result
  }
}