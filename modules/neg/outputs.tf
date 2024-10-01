output "name" {
  value = local.create ? coalesce(
    local.is_global ? one([google_compute_global_network_endpoint_group.default[one(local.gnegs).index_key].name]) : null,
    local.is_regional ? one([google_compute_region_network_endpoint_group.default[one(local.rnegs).index_key].name]) : null,
    local.is_zonal ? one([google_compute_network_endpoint_group.default[one(local.znegs).index_key].name]) : null,
    "error"
  ) : null
}
output "id" {
  value = local.create ? coalesce(
    local.is_global ? one([google_compute_global_network_endpoint_group.default[one(local.gnegs).index_key].id]) : null,
    local.is_regional ? one([google_compute_region_network_endpoint_group.default[one(local.rnegs).index_key].id]) : null,
    local.is_zonal ? one([google_compute_network_endpoint_group.default[one(local.znegs).index_key].id]) : null,
    "error"
  ) : null
}
output "self_link" {
  value = local.create ? coalesce(
    local.is_global ? one([google_compute_global_network_endpoint_group.default[one(local.gnegs).index_key].self_link]) : null,
    local.is_regional ? one([google_compute_region_network_endpoint_group.default[one(local.rnegs).index_key].self_link]) : null,
    local.is_zonal ? one([google_compute_network_endpoint_group.default[one(local.znegs).index_key].self_link]) : null,
    "error"
  ) : null
}
output "debug" { value = local.negs }
