output "name" { value = local.name }
output "id" {
  value = local.create ? coalesce(
    local.is_regional ? one(google_compute_region_backend_service.default).id : null,
    !local.is_regional ? one(google_compute_backend_service.default).id : null,
    "error",
  ) : null
}
output "self_link" {
  value = local.create ? coalesce(
    local.is_regional ? one(google_compute_region_backend_service.default).self_link : null,
    !local.is_regional ? one(google_compute_backend_service.default).self_link : null,
    "error",
  ) : null
}
