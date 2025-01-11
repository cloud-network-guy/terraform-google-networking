resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  mtu = coalesce(var.mtu, 0)
  routing_mode = upper(trimspace(
    var.global_routing == true ? "GLOBAL" : coalesce(var.routing_mode, "REGIONAL")
  ))
  auto_create_subnetworks  = coalesce(var.auto_create_subnetworks, false)
  enable_ula_internal_ipv6 = coalesce(var.enable_ula_internal_ipv6, false)
  network_firewall_policy_enforcement_order = upper(trimspace(
    coalesce(var.network_firewall_policy_enforcement_order, "AFTER_CLASSIC_FIREWALL")
  ))
  delete_default_routes_on_create = coalesce(var.delete_default_routes_on_create, false)
}

# VPC Network
resource "google_compute_network" "default" {
  count                                     = local.create ? 1 : 0
  project                                   = local.project
  name                                      = local.name
  description                               = local.description
  mtu                                       = local.mtu
  routing_mode                              = local.routing_mode
  auto_create_subnetworks                   = local.auto_create_subnetworks
  enable_ula_internal_ipv6                  = local.enable_ula_internal_ipv6
  network_firewall_policy_enforcement_order = local.network_firewall_policy_enforcement_order
  delete_default_routes_on_create           = local.delete_default_routes_on_create
  timeouts {
    create = null
    delete = null
    update = null
  }
}
resource "null_resource" "network" {
  for_each = toset(local.create ? [join("/", local.network_fields)] : [])
}

