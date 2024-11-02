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
output "psc_connected_endpoints" {
  value = local.create && local.is_regional && local.psc_publish ? one(google_compute_service_attachment.default).connected_endpoints : null
}
