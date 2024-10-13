output "backend_services" {
  value = { for k, v in var.backends : k => module.backends[k].backend_services }
}
#output "health_checks" {
#  value = { for k, v in var.backends : k => module.backends[k].health_checks }
#}
output "forwarding_rules" { value = { for k, v in var.frontends : k => module.frontends[k].forwarding_rules } }
output "ip_addresses" { value = { for k, v in var.frontends : k => module.frontends[k].ip_addresses } }

#output "debug" { value = { for k, v in local._backends : k => module.negs[k].debug } }
#output "new_negs" {
#  value = { for k, v in var.backends : k => module.backends[k].new_negs }
#}
