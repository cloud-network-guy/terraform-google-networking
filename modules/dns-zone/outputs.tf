output "name" { value = local.create ? one(google_dns_managed_zone.default).name : null }
output "id" { value = local.create ? one(google_dns_managed_zone.default).id : null }
output "managed_zone_id" { value = local.create ? one(google_dns_managed_zone.default).managed_zone_id : null }
output "name_servers" { value = local.create ? one(google_dns_managed_zone.default).name_servers : null }

