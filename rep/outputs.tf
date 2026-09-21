output "id" {
  description = "Resource ID of the regional endpoint."
  value       = google_network_connectivity_regional_endpoint.default.id
}

output "name" {
  description = "Name of the regional endpoint."
  value       = google_network_connectivity_regional_endpoint.default.name
}

output "ip_address" {
  description = "Internal IP address of the endpoint (use default for your private DNS record)."
  value       = google_network_connectivity_regional_endpoint.default.address
}

output "psc_forwarding_rule" {
  description = "Forwarding rule that the service created for default endpoint."
  value       = google_network_connectivity_regional_endpoint.default.psc_forwarding_rule
}

output "target_google_api" {
  description = "Regional Google API the endpoint connects to."
  value       = google_network_connectivity_regional_endpoint.default.target_google_api
}

output "static_ip_address" {
  description = "Reserved internal address resource details, or null when create_address is false."
  value = var.create_static_ip ? {
    id        = one(google_compute_address.default).id
    name      = one(google_compute_address.default).name
    self_link = one(google_compute_address.default).self_link
    address   = one(google_compute_address.default).address
  } : null
}
