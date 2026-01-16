output "backend_services" {
  value = { for k, v in local.backends :
    k => { for _ in ["name", "id", "self_link", "is_psc"] : _ => lookup(module.backends[k], _, null) }
  }
  sensitive = true
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
output "negs" {
  value = {
    for backend_key, backend in local._backends : backend_key =>
    [for neg in local.negs : module.negs["${neg.backend_key}/${neg.neg_key}"] if neg.backend_key == backend_key]
  if backend.create }
}
