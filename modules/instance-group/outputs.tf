output "name" {
  value = local.create ? coalesce(
    local.is_managed && local.is_regional ? one(google_compute_region_instance_group_manager.default).name : null,
    !local.is_managed && local.is_zonal ? one(google_compute_instance_group.default).name : null,
  ) : null
}
output "id" {
  value = local.create ? coalesce(
    local.is_managed && local.is_regional ? one(google_compute_region_instance_group_manager.default).id : null,
    !local.is_managed && local.is_zonal ? one(google_compute_instance_group.default).id : null,
  ) : null
}
output "self_link" {
  value = local.create ? coalesce(
    local.is_managed && local.is_regional ? one(google_compute_region_instance_group_manager.default).self_link : null,
    !local.is_managed && local.is_zonal ? one(google_compute_instance_group.default).self_link : null,
  ) : null
}
output "instance_group" {
  value = local.create && local.is_managed && local.is_regional ? one(google_compute_region_instance_group_manager.default).instance_group : null
}
output "region" {
  value = local.create ? local.region : null
}
output "zones" {
  value = local.create ? coalesce(
    local.is_managed && local.is_regional ? one(google_compute_region_instance_group_manager.default).distribution_policy_zones : null,
    local.is_zonal ? [one(google_compute_instance_group.default).zone] : null,
  ) : []
}
output "zone" {
  value = local.create && local.is_zonal ? one(google_compute_instance_group.default).zone : null
}
