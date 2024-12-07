# Global Locals
locals {
  type             = "INTERNAL"
  protocol         = "TCP"
  session_affinity = coalesce(var.session_affinity, "NONE")
}

# Healthchecks
locals {
  health_checks = { for k, v in var.health_checks : k =>
    merge(v, {
      project_id = coalesce(v.project_id, var.project_id)
      name       = coalesce(v.name, var.name_prefix != null ? "${var.name_prefix}-${k}" : k)
      region     = coalesce(v.region, var.region, "global")
      logging    = try(coalesce(v.logging, var.logging), null)
    })
  }
}
module "healthchecks" {
  source              = "../modules/healthcheck"
  for_each            = { for k, v in local.health_checks : k => v }
  project_id          = each.value.project_id
  name                = each.value.name
  description         = each.value.description
  region              = each.value.region
  host                = each.value.host
  port                = each.value.port
  protocol            = local.protocol
  request_path        = each.value.request_path
  response            = each.value.response
  interval            = each.value.interval
  timeout             = each.value.timeout
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  logging             = each.value.logging
  legacy              = each.value.legacy
}

locals {
  instance_groups = flatten([for k, v in var.backends :
    [for ig in v.instance_groups :
      {
        project     = var.project_id
        zone        = ig.zone
        name        = ig.name
        backend_key = k
        index_key   = "${var.project_id}/${ig.zone}/${ig.name}"
      } if length(lookup(v, "instance_groups", [])) > 0
    ]
  ])
  instance_group_keys = toset([for k, v in local.instance_groups : v.index_key])
}

# Use Data Source Query to lookup any pre-existing Instance Groups
data "google_compute_instance_group" "default" {
  for_each = { for k in local.instance_group_keys : k => element([for ig in local.instance_groups : ig if ig.index_key == k], 0) }
  project  = var.project_id
  zone     = each.value.zone
  name     = each.value.name
}

locals {
  backends = {
    for backend_key, backend in var.backends :
    backend_key => merge(backend, {
      create              = coalesce(backend.create, true)
      project_id          = coalesce(backend.project_id, var.project_id)
      host_project_id     = coalesce(backend.host_project_id, var.host_project_id, var.project_id)
      region              = coalesce(backend.region, var.region, "global")
      name                = coalesce(backend.name, var.name_prefix != null ? "${var.name_prefix}-${backend_key}" : backend_key)
      lb_session_affinity = coalesce(backend.session_affinity, local.session_affinity)
      health_checks       = coalesce(backend.health_checks, compact([backend.health_check]))
      groups = coalesce(
        backend.groups,
        [for k, v in local.instance_groups : data.google_compute_instance_group.default[v.index_key].self_link if v.backend_key == backend_key]
      )
    })
  }
}

module "backends" {
  source           = "../modules/lb-backend-new"
  for_each         = { for k, v in local.backends : k => v }
  create           = each.value.create
  project_id       = each.value.project_id
  host_project_id  = each.value.host_project_id
  type             = local.type
  protocol         = local.protocol
  session_affinity = each.value.session_affinity
  name             = each.value.name
  description      = each.value.description
  region           = each.value.region
  groups           = each.value.groups
  health_checks    = toset([for hc in keys(local.health_checks) : module.healthchecks[hc].self_link if contains(each.value.health_checks, hc)])
}


locals {
  frontends = { for k, v in var.frontends :
    k => {
      create          = coalesce(v.create, true)
      project_id      = coalesce(v.project_id, var.project_id)
      host_project_id = coalesce(v.host_project_id, var.host_project_id, var.project_id)
      region          = coalesce(v.region, var.region, "global")
      name            = coalesce(v.name, var.name_prefix != null ? "${var.name_prefix}-${k}" : k)
      network         = coalesce(v.network, var.network, "default")
      subnetwork      = coalesce(v.subnetwork, var.subnetwork, "default")
      address         = v.ip_address
      address_name    = coalesce(v.ip_address_name, "${var.name_prefix}-${k}-ilb")
      ports           = coalesce(v.ports, [])
      global_access   = coalesce(v.global_access, var.global_access, false)
      psc             = v.psc
      enable_ipv4     = true
      enable_ipv6     = false
    }
  }
}

module "frontends" {
  source          = "../modules/forwarding-rule"
  for_each        = { for k, v in local.frontends : k => v }
  create          = each.value.create
  project_id      = each.value.project_id
  host_project_id = each.value.host_project_id
  protocol        = local.protocol
  type            = local.type
  name            = each.value.name
  region          = each.value.region
  network         = each.value.network
  subnetwork      = each.value.subnetwork
  address         = each.value.address
  address_name    = each.value.address_name
  ports           = each.value.ports
  global_access   = each.value.global_access
  psc             = each.value.psc
  backend_service = module.backends[lookup(each.value, "backend", each.key)].id
}
