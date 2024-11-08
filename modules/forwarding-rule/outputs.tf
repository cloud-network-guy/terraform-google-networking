output "name" {
  value = local.name
}
output "address" {
  value = local.create_static_ip ? (
    local.is_regional ? one(google_compute_address.default).address : one(google_compute_global_address.default).address
  ) : null
}
output "address_name" {
  value = local.create_static_ip ? (
    local.is_regional ? one(google_compute_address.default).name : one(google_compute_global_address.default).name
  ) : null
}
output "psc_connected_endpoints" {
  value = local.create && local.is_regional && local.psc_publish ? one(google_compute_service_attachment.default).connected_endpoints : null
}
output "psc_connection_id" {
  value = local.create && local.is_psc && local.is_regional ? one(google_compute_forwarding_rule.default).psc_connection_id : null
}