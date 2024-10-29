output "dns_zones" {
  value = {
    for k, v in var.dns_zones :
    k => {
      name         = module.dns-zone[k].name
      id           = module.dns-zone[k].id
      name_servers = toset([for ns in module.dns-zone[k].name_servers : ns])
    } if v.create
  }
}
output "dns_policies" {
  value = {
    for k, v in var.dns_policies :
    k => {
      name     = module.dns-policy[k].name
      id       = module.dns-policy[k].id
      networks = module.dns-policy[k].networks
    } if v.create
  }
}
