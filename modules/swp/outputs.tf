output "gateway_name" {
  value = local.create ? one(google_network_services_gateway.default).name : null
}
output "gateway_id" {
  value = local.create ? one(google_network_services_gateway.default).id : null
}
output "gateway_addresses" {
  value = local.create ? one(google_network_services_gateway.default).addresses : null
}