output "name" { value = local.name }
output "address" {
  value = local.create ? local.is_rep ? one(google_compute_address.regional_endpoint).address : module.psc-endpoint.address : null
}
output "address_name" {
  value = local.create ? local.is_rep ? local.address_name : module.psc-endpoint.address_name : null
}
output "target" {
  value = local.create ? local.is_rep ? local.target : module.psc-endpoint.target : null
}
output "psc_connection_id" {
  value = local.create ? local.is_rep ? null : module.psc-endpoint.psc_connection_id : null
}

