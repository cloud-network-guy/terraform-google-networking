locals {
  create          = coalesce(var.create, true)
  project         = lower(trimspace(coalesce(var.project_id, var.project)))
  host_project_id = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
}

# DNS Zones
locals {
  dns_zones = { for k, v in var.dns_zones :
    k => merge(v, {
      name            = lower(trimspace(coalesce(v.name, k)))
      project_id      = lower(trimspace(coalesce(v.project_id, local.project)))
      host_project_id = lower(trimspace(coalesce(v.host_project_id, v.host_project, local.host_project_id)))
    })
  }
}
resource "null_resource" "dns_zone" {
  for_each = { for k, v in local.dns_zones : k => v }
}
module "dns-zone" {
  source              = "../modules/dns-zone"
  for_each            = { for k, v in local.dns_zones : k => v if local.create }
  project_id          = local.project
  host_project_id     = each.value.host_project_id
  create              = each.value.create
  name                = each.value.name
  description         = each.value.description
  dns_name            = each.value.dns_name
  visibility          = each.value.visibility
  peer_project        = each.value.peer_project
  peer_network        = each.value.peer_network
  target_name_servers = each.value.target_name_servers
  networks            = each.value.networks
  records             = each.value.records
  depends_on          = [null_resource.dns_zone]
}

# DNS Policies
locals {
  dns_policies = { for k, v in var.dns_policies :
    k => merge(v, {
      name = lower(trimspace(coalesce(v.name, k)))
    })
  }
}
resource "null_resource" "dns_policy" {
  for_each = { for k, v in local.dns_policies : k => v }
}
module "dns-policy" {
  source                    = "../modules/dns-policy"
  for_each                  = { for k, v in local.dns_policies : k => v if local.create }
  project_id                = local.project
  create                    = each.value.create
  name                      = each.value.name
  description               = each.value.description
  networks                  = each.value.networks
  enable_inbound_forwarding = each.value.enable_inbound_forwarding
  logging                   = each.value.logging
  target_name_servers       = each.value.target_name_servers
  depends_on                = [null_resource.dns_policy]
}
