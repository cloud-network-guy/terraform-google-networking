
# Get list of Zones for this region
data "google_compute_zones" "available" {
  count   = local.is_regional ? 1 : 0
  project = local.project
  region  = local.region
}

resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix   = "https://www.googleapis.com/compute/v1"
  create       = coalesce(var.create, true)
  project      = lower(trimspace(coalesce(var.project_id, var.project)))
  name         = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  is_regional  = var.region != null ? true : false
  region       = local.is_regional ? lower(trimspace(var.region)) : trimsuffix(local.zone, substr(local.zone, -2, 2))
  is_zonal     = var.zone != null ? true : false
  is_managed   = !local.is_zonal
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  network = coalesce(
    startswith(var.network, "projects/") ? var.network : null,
    startswith(var.network, local.api_prefix) ? var.network : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )
  autoscaling_mode                 = var.autoscaling_mode != null ? upper(trimspace(var.autoscaling_mode)) : "OFF"
  target_size                      = local.autoscaling_mode == "OFF" ? coalesce(var.target_size, 2) : null
  base_instance_name               = var.base_instance_name
  distribution_policy_target_shape = upper(coalesce(var.distribution_policy_target_shape, "EVEN"))
  update = {
    type                           = trimspace(upper(coalesce(var.update.type, "OPPORTUNISTIC")))
    instance_redistribution_type   = trimspace(upper(coalesce(var.update.instance_redistribution_type, "PROACTIVE")))
    minimal_action                 = trimspace(upper(coalesce(var.update.minimal_action, "REFRESH")))
    most_disruptive_allowed_action = trimspace(upper(coalesce(var.update.most_disruptive_action, "REPLACE")))
    replacement_method             = trimspace(upper(coalesce(var.update.replacement_method, "SUBSTITUTE")))
    max_unavailable_fixed          = length(local.distribution_policy_zones)
    max_unavailable_percent        = 0
    max_surge_fixed                = length(local.distribution_policy_zones)
    max_surge_percent              = 0
  }
  auto_healing_policies = {
    initial_delay_sec = coalesce(var.auto_healing_initial_delay, 300)
  }
  version_name              = "${local.name}-0"
  distribution_policy_zones = try(one(data.google_compute_zones.available).names, [for z in ["b", "c"] : "${local.region}-${z}"])
  _health_checks            = var.health_check != null ? [var.health_check] : coalesce(var.health_checks, [])
  health_checks = [for hc in local._health_checks :
    coalesce(
      startswith(hc, local.api_prefix) ? hc : null,
      startswith(hc, "projects/", ) ? "${local.api_prefix}/${hc}" : null,
      "${local.api_prefix}/projects/${local.project}/regions/${local.region}/healthChecks/${hc}",
    )
  ]
  _instance_template = var.instance_template != null ? trimspace(var.instance_template) : null
  instance_template = local._instance_template != null ? coalesce(
    startswith(local._instance_template, local.api_prefix) ? local._instance_template : null,
    startswith(local._instance_template, "projects/", ) ? "${local.api_prefix}/${local._instance_template}" : null,
    local.is_regional ? "${local.api_prefix}/projects/${local.project}/regions/${local.region}/instanceTemplates/${lower(local._instance_template)}" : null,
    "${local.api_prefix}/projects/${local.project}/global/instanceTemplates/${lower(local._instance_template)}",
  ) : null
}

# Regional Managed Instance Group
resource "null_resource" "mig" {
  count = local.create && local.is_managed && local.is_regional ? 1 : 0
}
resource "google_compute_region_instance_group_manager" "default" {
  count                            = local.create && local.is_managed && local.is_regional ? 1 : 0
  base_instance_name               = local.base_instance_name
  distribution_policy_target_shape = local.distribution_policy_target_shape
  distribution_policy_zones        = local.distribution_policy_zones
  list_managed_instances_results   = "PAGELESS"
  name                             = local.name
  project                          = local.project
  region                           = local.region
  target_pools                     = []
  target_size                      = local.target_size
  wait_for_instances               = false
  wait_for_instances_status        = "STABLE"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [distribution_policy_zones]
  }
  dynamic "auto_healing_policies" {
    for_each = local.health_checks
    content {
      health_check      = auto_healing_policies.value
      initial_delay_sec = local.auto_healing_policies.initial_delay_sec
    }
  }
  instance_lifecycle_policy {
    default_action_on_failure = "REPAIR"
    force_update_on_repair    = "NO"
  }
  version {
    name              = local.version_name
    instance_template = local.create ? local.instance_template : null
  }
  update_policy {
    type                           = local.update.type
    instance_redistribution_type   = local.update.instance_redistribution_type
    minimal_action                 = local.update.minimal_action
    most_disruptive_allowed_action = local.update.most_disruptive_allowed_action
    replacement_method             = local.update.replacement_method
    max_unavailable_fixed          = local.update.max_unavailable_fixed
    max_surge_fixed                = local.update.max_surge_fixed
  }
  depends_on = [null_resource.mig]
}

locals {
  auto_scaler_name   = lower(trimspace(coalesce(var.autoscaler_name, local.name)))
  autoscaling_policy = {
    mode            = local.autoscaling_mode
    min_replicas    = local.autoscaling_mode == "OFF" ? 0 : coalesce(var.min_replicas, 1)
    max_replicas    = local.autoscaling_mode == "OFF" ? 0 : coalesce(var.max_replicas, 10)
    cooldown_period = coalesce(var.cooldown_period, 60)
    cpu_utilization = {
      target            = coalesce(var.cpu_target, 0.60)
      predictive_method = coalesce(var.cpu_predictive_method, "NONE")
    }
  }
}

# Auto-Scaler
resource "google_compute_region_autoscaler" "default" {
  count   = local.autoscaling_mode == "OFF" ? 0 : 1
  name    = local.auto_scaler_name
  project = local.project
  region  = local.region
  target  = one(google_compute_region_instance_group_manager.default).self_link
  autoscaling_policy {
    max_replicas    = local.autoscaling_policy.max_replicas
    min_replicas    = local.autoscaling_policy.min_replicas
    cooldown_period = local.autoscaling_policy.cooldown_period
    mode            = local.autoscaling_policy.mode
    cpu_utilization {
      target            = local.autoscaling_policy.cpu_utilization.target
      predictive_method = local.autoscaling_policy.cpu_utilization.predictive_method
    }
  }
}

locals {
  zone         = local.is_zonal ? lower(trimspace(var.zone)) : null
  zones_prefix = local.zone != null ? "projects/${local.project}/zones/${local.zone}" : null
  instances    = [for i, v in coalesce(var.instances, compact([var.instance])) : lower(trimspace(v))]
  named_ports = [for i, v in coalesce(var.named_ports, []) :
    {
      name = lower(trimspace(coalesce(v.name, "https")))
      port = coalesce(v.port, 443)
    }
  ]
}

# Unmanaged Instance Group
resource "google_compute_instance_group" "default" {
  count     = local.create && local.is_zonal && !local.is_managed ? 1 : 0
  project   = local.project
  name      = local.name
  network   = local.network
  zone      = local.zone
  instances = formatlist("${local.api_prefix}/${local.zones_prefix}/instances/%s", local.instances)
  dynamic "named_port" {
    for_each = local.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}
