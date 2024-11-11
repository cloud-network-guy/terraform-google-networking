output "name" {
  value     = local.create ? one(google_compute_instance.default).name : null
  sensitive = true
}
output "id" {
  value     = local.create ? one(google_compute_instance.default).id : null
  sensitive = true
}
output "self_link" {
  value     = local.create ? one(google_compute_instance.default).self_link : null
  sensitive = true
}
output "zone" {
  value     = local.create ? one(google_compute_instance.default).zone : null
  sensitive = true
}
output "machine_type" {
  value     = local.create ? one(google_compute_instance.default).machine_type : null
  sensitive = true
}
output "subnetwork" {
  value     = local.create ? one(google_compute_instance.default).network_interface.0.subnetwork : null
  sensitive = true
}
output "network_ip" {
  value     = local.create ? one(google_compute_instance.default).network_interface.0.network_ip : null
  sensitive = true
}
#output "nat_ip" { value = local.create ? one(google_compute_instance.default).network_interface.0.network_interface.0.access_config.0.nat_ip : null }

