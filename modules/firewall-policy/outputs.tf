output "name" {
  value = local.create && local.is_network ? coalesce(
    local.is_global ? one(google_compute_network_firewall_policy.default).name : null,
    local.is_regional ? one(google_compute_region_network_firewall_policy.default).name : null,
  ) : null
}
output "id" {
  value = local.create && local.is_network ? coalesce(
    local.is_global ? one(google_compute_network_firewall_policy.default).id : null,
    local.is_regional ? one(google_compute_region_network_firewall_policy.default).id : null,
  ) : null
}
output "rule_tuple_count" {
  value = local.create && local.is_network ? coalesce(
    local.is_global ? one(google_compute_network_firewall_policy.default).rule_tuple_count : null,
    local.is_regional ? one(google_compute_region_network_firewall_policy.default).rule_tuple_count : null,
  ) : null
}

