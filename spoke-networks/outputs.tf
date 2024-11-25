output "network_name" { value = module.vpc-network.name }
output "network_id" { value = module.vpc-network.id }
output "network_self_link" { value = module.vpc-network.self_link }
output "peering_connections" { value = module.vpc-network.peering_connections }
output "subnets" { value = module.vpc-network.subnets }
output "cloud_nats" { value = module.vpc-network.cloud_nats }
output "spoke_vpn_tunnels" { value = module.vpn-to-hub.vpn_tunnels }
