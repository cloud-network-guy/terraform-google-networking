
output "name" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_legacy ? google_compute_region_health_check.default[one(local.healthchecks).index_key].name : null,
    !local.is_regional && !local.is_legacy ? google_compute_health_check.default[one(local.healthchecks).index_key].name : null,
    local.is_legacy && local.is_http ? google_compute_http_health_check.default[one(local.healthchecks).index_key].name : null,
    local.is_legacy && local.is_https ? google_compute_https_health_check.default[one(local.healthchecks).index_key].name : null,
    "error"
  ) : null
}

output "id" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_legacy ? google_compute_region_health_check.default[one(local.healthchecks).index_key].id : null,
    !local.is_regional && !local.is_legacy ? google_compute_health_check.default[one(local.healthchecks).index_key].id : null,
    local.is_legacy && local.is_http ? google_compute_http_health_check.default[one(local.healthchecks).index_key].id : null,
    local.is_legacy && local.is_https ? google_compute_https_health_check.default[one(local.healthchecks).index_key].id : null,
    "error"
  ) : null
}

output "self_link" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_legacy ? google_compute_region_health_check.default[one(local.healthchecks).index_key].self_link : null,
    !local.is_regional && !local.is_legacy ? google_compute_health_check.default[one(local.healthchecks).index_key].self_link : null,
    local.is_legacy && local.is_http ? google_compute_http_health_check.default[one(local.healthchecks).index_key].self_link : null,
    local.is_legacy && local.is_https ? google_compute_https_health_check.default[one(local.healthchecks).index_key].self_link : null,
    "error"
  ) : null
}

output "region" { value = local.is_regional ? local.region : null }
