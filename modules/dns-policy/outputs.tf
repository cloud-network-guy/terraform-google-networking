output "name" { value = local.create ? one(google_dns_policy.default).name : null }
output "id" { value = local.create ? one(google_dns_policy.default).id : null }
output "networks" { value = local.create ? [for n in one(google_dns_policy.default).networks : n.network_url] : null }

