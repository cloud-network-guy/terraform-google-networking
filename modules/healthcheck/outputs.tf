
output "name" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_legacy ? one(google_compute_region_health_check.default).name : null,
    !local.is_regional && !local.is_legacy ? one(google_compute_health_check.default).name : null,
    local.is_legacy && local.is_http ? one(google_compute_http_health_check.default).name : null,
    local.is_legacy && local.is_https ? one(google_compute_https_health_check.default).name : null,
    "error"
  ) : null
}

output "id" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_legacy ? one(google_compute_region_health_check.default).id : null,
    !local.is_regional && !local.is_legacy ? one(google_compute_health_check.default).id : null,
    local.is_legacy && local.is_http ? one(google_compute_http_health_check.default).id : null,
    local.is_legacy && local.is_https ? one(google_compute_https_health_check.default).id : null,
    "error"
  ) : null
}

output "self_link" {
  value = local.create ? coalesce(
    local.is_regional && !local.is_legacy ? one(google_compute_region_health_check.default).self_link : null,
    !local.is_regional && !local.is_legacy ? one(google_compute_health_check.default).self_link : null,
    local.is_legacy && local.is_http ? one(google_compute_http_health_check.default).self_link : null,
    local.is_legacy && local.is_https ? one(google_compute_https_health_check.default).self_link : null,
    "error"
  ) : null
}

output "region" { value = local.is_regional ? local.region : null }
