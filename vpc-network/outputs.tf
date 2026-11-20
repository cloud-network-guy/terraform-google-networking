output "network_name" { value = module.vpc-network.name }
output "network_id" { value = module.vpc-network.id }
output "network_self_link" { value = module.vpc-network.self_link }
output "peering_connections" { value = module.vpc-network.peering_connections }
#output "subnets" { value = one(module.vpc-network.vpc_networks).subnets }
#output "cloud_rouers" { value = one(module.vpc-network.vpc_networks).cloud_routers }
#output "cloud_nats" { value = one(module.vpc-network.vpc_networks).cloud_nats }
