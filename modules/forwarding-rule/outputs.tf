output "name" {
  value = local.name
}
output "address" {
  value = local.create && local.create_static_ip ? coalesce(
    local.is_global ? one(google_compute_global_address.default).address : null,
    local.is_regional ? one(google_compute_address.default).address : null,
  ) : null
}
output "address_name" {
  value = local.create && local.create_static_ip ? coalesce(
    local.is_global ? one(google_compute_global_address.default).name : null,
    local.is_regional ? one(google_compute_address.default).name : null,
  ) : null
}
output "psc_connected_endpoints" {
  value = local.create && local.psc_publish ? coalesce(
    local.is_global ? "not_supported" : null,
    local.is_regional ? one(google_compute_service_attachment.default).connected_endpoints : null,
  ) : null
}
output "psc_connection_id" {
  value = local.create && local.is_psc ? coalesce(
    local.is_global ? one(google_compute_global_forwarding_rule.default).psc_connection_id : null,
    local.is_regional ? one(google_compute_forwarding_rule.default).psc_connection_id : null,
  ) : null
}
output "target" {
  value = local.create && local.is_psc ? coalesce(
    local.is_global ? one(google_compute_global_forwarding_rule.default).target : null,
    local.is_regional ? one(google_compute_forwarding_rule.default).target : null,
  ) : null
}
