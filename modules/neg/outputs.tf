output "name" {
  value = local.create ? coalesce(
    local.is_global ? one(google_compute_global_network_endpoint_group.default).name : null,
    local.is_regional ? one(google_compute_region_network_endpoint_group.default).name : null,
    local.is_zonal ? one(google_compute_network_endpoint_group.default).name : null,
    "error"
  ) : null
}
output "id" {
  value = local.create ? coalesce(
    local.is_global ? one(google_compute_global_network_endpoint_group.default).id : null,
    local.is_regional ? one(google_compute_region_network_endpoint_group.default).id : null,
    local.is_zonal ? one(google_compute_network_endpoint_group.default).id : null,
    "error"
  ) : null
}
output "self_link" {
  value = local.create ? coalesce(
    local.is_global ? one(google_compute_global_network_endpoint_group.default).self_link : null,
    local.is_regional ? one(google_compute_region_network_endpoint_group.default).self_link : null,
    local.is_zonal ? one(google_compute_network_endpoint_group.default).self_link : null,
    "error"
  ) : null
}
output "endpoints" { value = local.create ? local.endpoints : null }
