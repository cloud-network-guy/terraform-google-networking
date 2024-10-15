output "backend_services" {
  value = { for k, v in local.backends :
    k => { for _ in ["name", "id", "self_link"] : _ => lookup(module.backends[k], _, null) }
  }
}
output "forwarding_rules" {
  value = { for k, v in local.frontends :
    k => { for _ in ["name", "id", "self_link"] : _ => lookup(module.frontends[k], _, null) }
  }
}
output "security_policies" {
  value = { for k, v in local.security_policies :
    k => { for _ in ["name", "id", "self_link"] : _ => lookup(module.cloudarmor[k], _, null) }
  }
}
output "ip_addresses" {
  value = { for k, v in var.frontends :
    k => module.frontends[k].ip_addresses
  }
}

#output "debug" { value = { for k, v in local._backends : k => module.negs[k].debug } }
#output "new_negs" {
#  value = { for k, v in var.backends : k => module.backends[k].new_negs }
#}
