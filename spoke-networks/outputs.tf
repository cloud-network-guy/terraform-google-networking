output "network_name" { value = one(module.vpc-network.vpc_networks).name }
output "network_id" { value = one(module.vpc-network.vpc_networks).id }
output "network_self_link" { value = one(module.vpc-network.vpc_networks).self_link }
output "peering_connections" { value = one(module.vpc-network.vpc_networks).peering_connections }
output "subnets" { value = one(module.vpc-network.vpc_networks).subnets }
output "cloud_nats" { value = one(module.vpc-network.vpc_networks).cloud_nats }
output "spoke_vpn_tunnels" { value = module.vpn-to-hub.vpn_tunnels }
