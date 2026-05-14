output "name" { value = local.name }
output "address" { value = local.create ? module.psc-endpoint.address : null }
output "address_name" { value = local.create ? module.psc-endpoint.address_name : null }
output "target" { value = local.create ? module.psc-endpoint.target : null }
output "psc_connection_id" {
  value = local.create ? module.psc-endpoint.psc_connection_id : null
}

