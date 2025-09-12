locals {
  create              = coalesce(var.create, true)
  project             = lower(trimspace(coalesce(var.project_id, var.project)))
  region              = var.region != null ? lower(trimspace(var.region)) : null
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
      logging     = coalesce(var.healthcheck_logging, false)
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
  logging     = each.value.logging
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
    k => {
      name_prefix           = v.name_prefix
      region                = v.region
      network               = v.network
      subnetwork            = v.subnet
      machine_type          = coalesce(v.machine_type, var.machine_type, "e2-small")
      disk_type             = coalesce(v.disk_type, var.disk_type, "pd-standard")
      disk_size             = coalesce(v.disk_size, var.disk_size, 10)
      os_project            = coalesce(v.os_project, var.os_project, "debian-cloud")
      os                    = coalesce(v.os, var.os, "debian-12")
      service_account_email = var.service_account_email
      network_tags          = var.network_tags
      labels                = var.labels
      startup_script        = try(coalesce(v.startup_script, var.startup_script), null)
    } if length(v.instance_groups) == 0
  }
}

# Instance Templates
module "instance-template" {
  source                = "../modules/instance-template"
  for_each              = { for k, v in local.instance_templates : k => v }
  project_id            = var.project_id
  region                = each.value.region
  name_prefix           = each.value.name_prefix
  service_account_email = each.value.service_account_email
  network               = each.value.network
  subnetwork            = each.value.subnetwork
  network_tags          = each.value.network_tags
  machine_type          = each.value.machine_type
  disk = {
    type    = each.value.disk_type
    size_gb = each.value.disk_size
  }
  os_project     = each.value.os_project
  os             = each.value.os
  labels         = each.value.labels
  startup_script = each.value.startup_script
  metadata = {
    enable-guest-attributes = "true"
    enable-osconfig         = "true"
  }
}

locals {
  # Managed Instance Groups
  migs = { for k, v in local.deployments :
    k => {
      deployment_key        = k
      region                = v.region
      name                  = "${var.name_prefix}-${v.region}"
      base_instance_name    = "${var.name_prefix}-${k}"
      network               = v.network
      target_size           = try(coalesce(v.target_size, var.target_size), null)
      min_replicas          = try(coalesce(v.min_replicas, var.min_replicas), null)
      max_replicas          = try(coalesce(v.max_replicas, var.max_replicas), null)
      cpu_target            = try(coalesce(v.cpu_target, var.cpu_target), null)
      cpu_predictive_method = try(coalesce(v.cpu_predictive_method, var.cpu_predictive_method), null)
      health_checks         = [module.healthcheck[k].id]
      cooldown_period       = var.cool_down_period
      instance_template     = module.instance-template[k].id
      zone                  = null
    } if length(v.instance_groups) == 0
  }
  # Unmanaged Instance Groups
  umigs = { for k, v in local.deployments :
    k => [for ig in coalesce(v.instance_groups, []) :
      {
        deployment_key = k
        network        = v.network
        name           = ig.name
        zone           = ig.zone
        instances      = ig.instances
        region         = null
      } if length(coalesce(ig.instances, [])) > 0
    ]
  }
  instance_groups = concat(
    [for k, v in local.migs :
      merge(v, {
        index_key = "${v.region}/${v.name}"
      })
    ],
    flatten([for k, v in local.umigs :
      [for umig in v :
        merge(umig, {
          index_key = "${umig.zone}/${umig.name}"
        })
      ]
    ])
  )
}

# Instance Groups
module "instance-groups" {
  source                = "../modules/instance-group"
  for_each              = { for i, v in local.instance_groups : v.index_key => v }
  project_id            = var.project_id
  host_project_id       = var.host_project_id
  name                  = each.value.name
  network               = each.value.network
  base_instance_name    = lookup(each.value, "base_instance_name", null)
  region                = lookup(each.value, "region", null)
  zone                  = lookup(each.value, "zone", null)
  instances             = lookup(each.value, "instances", null)
  target_size           = lookup(each.value, "target_size", null)
  health_checks         = lookup(each.value, "health_checks", null)
  instance_template     = lookup(each.value, "instance_template", null)
  autoscaling_mode      = lookup(each.value, "min_replicas", null) != null ? "ON" : "OFF"
  autoscaler_name       = var.name_prefix
  min_replicas          = lookup(each.value, "min_replicas", null)
  max_replicas          = lookup(each.value, "max_replicas", null)
  cpu_target            = lookup(each.value, "cpu_target", null)
  cpu_predictive_method = lookup(each.value, "cpu_predictive_method", null)
  cooldown_period       = lookup(each.value, "cooldown_period", null)
  update = {
    type                   = "PROACTIVE"
    minimal_action         = "REPLACE"
    most_disruptive_action = "REPLACE"
  }
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
      groups = coalescelist(
        compact([for ig in local.instance_groups : module.instance-groups[ig.index_key].instance_group if ig.deployment_key == k]),
        compact([for ig in local.instance_groups : module.instance-groups[ig.index_key].id if ig.deployment_key == k]),
      )
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
      create        = coalesce(v.create_ilb, true)
      name          = coalesce(v.forwarding_rule_name, "${var.name_prefix}-${k}")
      region        = v.region
      network       = v.network
      subnetwork    = v.subnet
      address       = v.ip_address
      address_name  = coalesce(v.ip_address_name, "${var.name_prefix}-${k}-ilb")
      ports         = v.ports
      global_access = coalesce(v.global_access, var.global_access)
      psc           = v.psc
      enable_ipv4   = true
      enable_ipv6   = false
    }
  }
}

module "lb-frontend" {
  source          = "../modules/forwarding-rule"
  for_each        = { for k, v in local.lb_frontends : k => v }
  project_id      = var.project_id
  host_project_id = var.host_project_id
  protocol        = local.lb_protocol
  create          = each.value.create
  name            = each.value.name
  region          = each.value.region
  network         = each.value.network
  subnetwork      = each.value.subnetwork
  address         = each.value.address
  address_name    = each.value.address_name
  ports           = each.value.ports
  global_access   = each.value.global_access
  psc             = each.value.psc
  backend_service = module.lb-backend[each.key].id
}
