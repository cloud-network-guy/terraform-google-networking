resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix     = "https://www.googleapis.com/compute/v1"
  create         = coalesce(var.create, true)
  project        = lower(trimspace(coalesce(var.project_id, var.project)))
  host_project   = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  name           = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description    = var.description != null ? trimspace(var.description) : null
  is_regional    = var.region != null ? true : false
  region         = local.is_regional ? var.region : "global"
  type           = upper(coalesce(var.type, "INTERNAL"))
  is_internal    = local.type == "INTERNAL" || local.subnetwork != null ? true : false
  protocol       = var.protocol != null ? upper(trimspace(var.protocol)) : "TCP"
  is_tcp         = local.protocol == "TCP" ? true : false
  _health_checks = var.health_check != null ? [var.health_check] : coalesce(var.health_checks, [])
  health_checks = [for hc in local._health_checks :
    coalesce(
      startswith(hc, local.api_prefix) ? hc : null,
      startswith(hc, "projects/", ) ? "${local.api_prefix}/${hc}" : null,
      local.is_regional ? "${local.api_prefix}/projects/${local.project}/regions/${local.region}/healthChecks/${hc}" : null,
    )
  ]
  network = coalesce(
    startswith(var.network, local.api_prefix) ? var.network : null,
    startswith(var.network, "projects/") ? "${local.api_prefix}/${var.network}" : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )
  subnetwork = coalesce(
    startswith(var.subnetwork, local.api_prefix) ? var.subnetwork : null,
    startswith(var.subnetwork, "projects/", ) ? "${local.api_prefix}/${var.subnetwork}" : null,
    "projects/${local.host_project}/regions/${local.region}/subnetworks/${coalesce(var.subnetwork, "default")}",
  )
  backend = {
    capacity_scaler              = local.is_tcp ? 0 : null
    balancing_mode               = local.is_tcp ? "CONNECTION" : null
    max_connections              = local.is_tcp && local.is_internal ? 0 : null
    max_connections_per_endpoint = 0
    max_connections_per_instance = 0
    max_rate                     = 0
    max_rate_per_endpoint        = 0
    max_rate_per_instance        = 0
    max_utilization              = 0
  }
  logging = coalesce(var.logging, false)
  log_config = {
    enable      = local.logging ? local.logging : null
    sample_rate = local.logging ? coalesce(var.logging_sample_rate, 1) : null
  }
  groups = [for group in coalesce(var.groups, []) :
    (startswith(group, local.api_prefix) ? group : "${local.api_prefix}/${group}")
  ]
  is_classic                      = coalesce(var.classic, false)
  is_application                  = false
  load_balancing_scheme           = local.is_application && !local.is_classic ? "${local.type}_MANAGED" : local.type
  locality_lb_policy              = local.is_tcp ? "" : "ROUND_ROBIN"
  session_affinity                = local.is_tcp ? coalesce(var.session_affinity, "NONE") : null
  connection_draining_timeout_sec = coalesce(var.connection_draining_timeout_sec, 300)
  timeout_sec                     = local.is_tcp ? null : coalesce(var.timeout, 30)
}

resource "null_resource" "backend_service" {
  count = local.create ? 1 : 0
}

# Regional Backend Service
resource "google_compute_region_backend_service" "default" {
  count                           = local.create && local.is_regional ? 1 : 0
  project                         = local.project
  name                            = local.name
  description                     = local.description
  protocol                        = local.protocol
  load_balancing_scheme           = local.load_balancing_scheme
  locality_lb_policy              = local.locality_lb_policy
  session_affinity                = local.session_affinity
  health_checks                   = local.health_checks
  timeout_sec                     = local.timeout_sec
  connection_draining_timeout_sec = local.connection_draining_timeout_sec
  dynamic "backend" {
    for_each = local.groups
    content {
      group                        = backend.value
      capacity_scaler              = local.backend.capacity_scaler
      balancing_mode               = local.backend.balancing_mode
      max_connections              = local.backend.max_connections
      max_connections_per_endpoint = local.backend.max_connections_per_endpoint
      max_connections_per_instance = local.backend.max_connections_per_instance
      max_rate                     = local.backend.max_rate
      max_rate_per_endpoint        = local.backend.max_rate_per_endpoint
      max_rate_per_instance        = local.backend.max_connections_per_instance
      max_utilization              = local.backend.max_utilization
    }
  }
  dynamic "log_config" {
    for_each = local.logging ? [true] : []
    content {
      enable      = local.log_config.enable
      sample_rate = local.log_config.sample_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = local.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  depends_on = [null_resource.backend_service]
  region     = local.region
  network    = local.is_tcp ? null : local.network
}

# Glocal Backend Service
resource "google_compute_backend_service" "default" {
  count                           = local.create && !local.is_regional ? 1 : 0
  project                         = local.project
  name                            = local.name
  description                     = local.description
  protocol                        = local.protocol
  load_balancing_scheme           = local.load_balancing_scheme
  locality_lb_policy              = local.locality_lb_policy
  session_affinity                = local.session_affinity
  health_checks                   = local.health_checks
  timeout_sec                     = local.timeout_sec
  connection_draining_timeout_sec = local.connection_draining_timeout_sec
  dynamic "backend" {
    for_each = local.groups
    content {
      group                        = backend.value
      capacity_scaler              = local.backend.capacity_scaler
      balancing_mode               = local.backend.balancing_mode
      max_connections              = local.backend.max_connections
      max_connections_per_endpoint = local.backend.max_connections_per_endpoint
      max_connections_per_instance = local.backend.max_connections_per_instance
      max_rate                     = local.backend.max_rate
      max_rate_per_endpoint        = local.backend.max_rate_per_endpoint
      max_rate_per_instance        = local.backend.max_connections_per_instance
      max_utilization              = local.backend.max_utilization
    }
  }
  dynamic "log_config" {
    for_each = local.logging ? [true] : []
    content {
      enable      = local.log_config.enable
      sample_rate = local.log_config.sample_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = local.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  depends_on = [null_resource.backend_service]
}

