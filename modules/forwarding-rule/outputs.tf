output "name" { value = local.name }
output "address" {
  value = local.create ? coalesce(
    local.is_regional ? one(google_compute_address.default).address : null,
    "error",
  ) : null
}
output "address_name" {
  value = local.create ? coalesce(
    local.is_regional ? one(google_compute_address.default).name : null,
    "error",
  ) : null
}
output "psc_connection_id" {
  value = local.create && local.is_psc ? coalesce(
    local.is_regional ? one(google_compute_forwarding_rule.default).psc_connection_id : null,
    "error",
  ) : null
}
