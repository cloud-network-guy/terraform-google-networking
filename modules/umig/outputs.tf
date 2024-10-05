output "name" {
  value = local.name
}
output "region" {
  value = local.region
}
output "zone" {
  value = local.zone
}
output "network" {
  value = one([for i, v in local.umigs : v.network])
}
output "index_key" {
  value = one([for i, v in local.umigs : v.index_key]) 
}
output "id" {
  value = local.create ? one([for i, v in local.umigs : google_compute_instance_group.default[i].id]) : null
}
output "self_link" {
  value = local.create ? one([for i, v in local.umigs : google_compute_instance_group.default[i].self_link]) : null
}
