/*
output "interfaces" {
  description = "Map (keyed by interface name) of the created google_compute_router_interface resources."
  value       = google_compute_router_interface.this
}

output "bgp_peers" {
  description = "Map (keyed by peer name) of the created google_compute_router_peer resources."
  value       = google_compute_router_peer.this
  sensitive   = true # may contain md5_authentication_key values
}

output "bgp_peer_ip_addresses" {
  description = "Map (keyed by peer name) of the router-side and peer-side IP addresses assigned/used for the session."
  value = {
    for k, v in google_compute_router_peer.this : k => {
      ip_address      = v.ip_address
      peer_ip_address = v.peer_ip_address
    }
  }
}
*/
output "interface_ip_range" {
  description = ""
  value = local.create ? one(google_compute_router_interface.default).ip_range : null 
}
output "peer_ip_address" {
  description = ""
  value = local.create ? one(google_compute_router_peer.default).peer_ip_address : null
}