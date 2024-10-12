output "mig_ids" {
  value = {
    for k, v in local.migs :
    k => one([for mig in module.instances[k].migs : mig.id])
  }
}
output "umig_ids" {
  value = { for k, v in local.umigs :
    k => [for umig in module.instances[k].umigs : umig.id]
  }
}
output "ilbs_addresses" {
  value = { for k, v in local.lb_frontends :
    k => module.lb-frontend[k].ip_addresses
  }
}
output "connected_endpoints" {
  value = { for k, v in local.lb_frontends :
    k => module.lb-frontend[k].forwarding_rules[0].connected_endpoints
  }
}