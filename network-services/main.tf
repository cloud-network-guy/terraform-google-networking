locals {
  lb_type             = "INTERNAL"
  lb_protocol         = "TCP"
  lb_session_affinity = coalesce(var.session_affinity, "NONE")
  deployments = { for k, v in var.deployments :
    k => merge(v, {
      name_prefix     = var.name_prefix
      region          = coalesce(v.region, k)
      ports           = coalesce(v.ports, var.ports)
      network         = coalesce(v.network, var.network, "default")
      subnet          = coalesce(v.subnet, "default")
      instance_groups = coalesce(v.instance_groups, [])
    }) if coalesce(v.enabled, true) == true
  }
}

# TCP Regional Healthcheck for the first port of service
locals {
  healthchecks = { for k, v in local.deployments :
    k => {
      name        = "${v.name_prefix}-${v.region}-${v.ports[0]}"
      description = "Regional Healthcheck for ${v.name_prefix}"
      region      = v.region
      protocol    = local.lb_protocol
      port        = v.ports[0]
      interval    = var.healthcheck_interval
    }
  }
}
module "healthcheck" {
  source      = "../modules/healthcheck"
  for_each    = { for k, v in local.healthchecks : k => v }
  project_id  = var.project_id
  name        = each.value.name
  description = each.value.description
  region      = each.value.region
  protocol    = each.value.protocol
  port        = each.value.port
  interval    = each.value.interval
}

# Iterate over deployments and set some variables for Instance Template/MIG/AutoScaler
locals {
  use_autoscaling = coalesce(var.autoscaling_mode, "OFF") == "ON" || coalesce(var.min_replicas, 0) > 0 ? true : false
  existing_igs    = [] # { for k, v in var.deployments : k => v.instance_groups if length(coalesce(v.instance_groups, [])) > 0 }
  lb_deployments = { for k, v in var.deployments : k =>
    merge(v, {
      region                = coalesce(v.region, k)
      base_instance_name    = "${var.name_prefix}-${k}"
      ip_address_name       = coalesce(v.ip_address_name, "${var.name_prefix}-${coalesce(v.region, k)}-ilb")
      forwarding_rule_name  = coalesce(v.forwarding_rule_name, "${var.name_prefix}-${coalesce(v.region, k)}")
      global_access         = coalesce(v.global_access, var.global_access, false)
      ports                 = try(coalesce(v.ports, var.ports), null)
      cpu_target            = coalesce(v.cpu_target, var.cpu_target, 0.6)
      cpu_predictive_method = coalesce(v.cpu_predictive_method, var.cpu_predictive_method, "NONE")
    })
  }
}

# Instance Template + Managed Instance Group, or Just Unmanaged Instance Group
locals {
  instance_templates = { for k, v in local.deployments :
    k => [merge(v, {
      name                  = var.name_prefix
      service_account_email = var.service_account_email
      network_tags          = var.network_tags
      machine_type          = var.machine_type
      disk_size             = var.disk_size
      image                 = var.image
      os_project            = var.os_project
      os                    = var.os
      labels                = var.labels
      startup_script        = var.startup_script
    })] if length(v.instance_groups) == 0
  }
  migs = { for k, v in local.deployments :
    k => [merge(v, {
      name                                = "${var.name_prefix}-${v.region}"
      base_instance_name                  = "${var.name_prefix}-${k}"
      min_replicas                        = try(coalesce(v.min_replicas, var.min_replicas), null)
      max_replicas                        = try(coalesce(v.max_replicas, var.max_replicas), null)
      cpu_target                          = try(coalesce(v.cpu_target, var.cpu_target), null)
      cpu_predictive_method               = try(coalesce(v.cpu_predictive_method, var.cpu_predictive_method), null)
      healthchecks                        = [{ id = module.healthcheck[k].id }]
      cooldown_period                     = var.cool_down_period
      update_type                         = "PROACTIVE"
      distribution_policy_target_shape    = "EVEN"
      update_instance_redistribution_type = "PROACTIVE"
      update_minimal_action               = "REPLACE"
      update_most_disruptive_action       = "REPLACE"
    })] if length(v.instance_groups) == 0
  }
  # Create new Unmanaged instance groups, if required
  umigs = { for k, v in local.deployments :
    k => [for ig in coalesce(v.instance_groups, []) :
      {
        network   = v.network
        name      = ig.name
        zone      = ig.zone
        instances = ig.instances
    } if length(coalesce(ig.instances, [])) > 0]
  }
}
module "instances" {
  source             = "../modules/instances"
  for_each           = { for k, v in local.deployments : k => v }
  project_id         = var.project_id
  host_project_id    = var.host_project_id
  instance_templates = lookup(local.instance_templates, each.key, [])
  migs               = lookup(local.migs, each.key, [])
  umigs              = lookup(local.umigs, each.key, [])
}

# Enable IAM roles required for Ops Agent
locals {
  ops_agent_iam_members = { for i, v in ["logging.logWriter", "monitoring.metricWriter"] :
    i => {
      member = "serviceAccount:${var.service_account_email}"
      role   = "roles/${v}"
    } if var.service_account_email != null
  }
}
resource "google_project_iam_member" "ops_agent" {
  for_each = local.ops_agent_iam_members
  project  = var.project_id
  member   = each.value.member
  role     = each.value.role
}

# Load Balancer Backend Service
locals {
  lb_backends = { for k, v in local.deployments :
    k => {
      create           = coalesce(v.create_ilb, true)
      type             = local.lb_type
      protocol         = local.lb_protocol
      session_affinity = local.lb_session_affinity
      name             = "${var.name_prefix}-${k}"
      description      = "${var.name_prefix} backend service for '${k}'"
      region           = v.region
      groups = try(coalescelist(
        lookup(local.migs, k, null) != null ? [one(module.instances[k].migs).instance_group] : null,
        lookup(local.umigs, k, null) != null ? [for umig in module.instances[k].umigs : umig.id] : null,
        [for ig in v.instance_groups : "projects/${var.project_id}/zones/${ig.zone}/instanceGroups/${ig.name}"],
      ), null)
      health_checks = [module.healthcheck[k].self_link]
    }
  }
}
module "lb-backend" {
  source           = "../modules/lb-backend"
  for_each         = { for k, v in local.lb_backends : k => v }
  project_id       = var.project_id
  host_project_id  = var.host_project_id
  type             = each.value.type
  protocol         = each.value.protocol
  session_affinity = each.value.session_affinity
  create           = each.value.create
  name             = each.value.name
  description      = each.value.description
  region           = each.value.region
  groups           = each.value.groups
  health_checks    = each.value.health_checks
}

# Load Balancer Frontend (Forwarding Rule)
locals {
  lb_frontends = { for k, v in local.deployments :
    k => {
      create          = coalesce(v.create_ilb, true)
      name            = coalesce(v.forwarding_rule_name, "${var.name_prefix}-${k}")
      region          = v.region
      network         = v.network
      subnet          = v.subnet
      ip_address      = v.ip_address
      ip_address_name = coalesce(v.ip_address_name, "${var.name_prefix}-${k}-ilb")
      ports           = v.ports
      global_access   = coalesce(v.global_access, var.global_access)
      psc             = v.psc
      default_service = module.lb-backend[k].backend_services[0].id
      enable_ipv4     = true
      enable_ipv6     = false
    }
  }
}
module "lb-frontend" {
  source          = "../modules/lb-frontend"
  for_each        = { for k, v in local.lb_frontends : k => v }
  project_id      = var.project_id
  host_project_id = var.host_project_id
  type            = local.lb_type
  create          = each.value.create
  name            = each.value.name
  region          = each.value.region
  network         = each.value.network
  subnet          = each.value.subnet
  ip_address      = each.value.ip_address
  ip_address_name = each.value.ip_address_name
  ports           = each.value.ports
  global_access   = each.value.global_access
  psc             = each.value.psc
  default_service = each.value.default_service
  enable_ipv4     = each.value.enable_ipv4
  enable_ipv6     = each.value.enable_ipv6
}
