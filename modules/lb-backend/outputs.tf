output "name" { value = local.name }
output "id" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_psc ? one(google_compute_region_backend_service.default).id : null,
    local.is_global || local.is_psc ? one(google_compute_backend_service.default).id : null,
    "error",
  ) : null
}
output "self_link" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_psc ? one(google_compute_region_backend_service.default).self_link : null,
    local.is_global || local.is_psc ? one(google_compute_backend_service.default).self_link : null,
    "error",
  ) : null
}
output "is_psc" { value = local.create ? local.is_psc : null }
output "is_global" { value = local.create ? local.is_global : null }
output "is_regional" { value = local.create ? local.is_regional : null }