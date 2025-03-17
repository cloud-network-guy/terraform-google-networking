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
  region         = lower(trimspace(coalesce(var.region, "global")))
  is_regional    = local.region != "global" ? true : false
  type           = upper(trimspace(coalesce(var.type, "INTERNAL")))
  is_internal    = local.type == "INTERNAL" ? true : false
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
  _network = lower(trimspace(coalesce(var.network, "default")))
  network = coalesce(
      startswith(local._network, local.api_prefix) ? local._network : null,
    startswith(local._network, "projects/") ? "${local.api_prefix}/${local._network}" : null,
    "projects/${local.host_project}/global/networks/${local._network}",
  )
  _subnetwork = lower(trimspace(coalesce(var.subnetwork, "default")))
  subnetwork = coalesce(
    startswith(local._subnetwork, local.api_prefix) ? local._subnetwork : null,
    startswith(local._subnetwork, "projects/", ) ? "${local.api_prefix}/${local._subnetwork}" : null,
    "projects/${local.host_project}/regions/${local.region}/subnetworks/${coalesce(local._subnetwork, "default")}",
  )
  logging = coalesce(var.logging, false)
  log_config = {
    enable      = local.logging ? local.logging : null
    sample_rate = local.logging ? coalesce(var.logging_sample_rate, 1) : null
  }
  groups = [for group in coalesce(var.groups, []) :
    (startswith(group, local.api_prefix) ? group : "${local.api_prefix}/${group}")
  ]
  is_igs             = length([for _ in local.groups : _ if strcontains(_, "/instanceGroups/")]) > 0 ? true : false
  is_negs            = length([for _ in local.groups : _ if strcontains(_, "/networkEndpointGroups/")]) > 0 ? true : false
  is_gnegs           = length([for _ in local.groups : _ if local.is_negs && strcontains(_, "/global/")]) > 0 ? true : false
  is_rnegs           = length([for _ in local.groups : _ if local.is_negs && strcontains(_, "/regions/")]) > 0 ? true : false
  is_znegs           = length([for _ in local.groups : _ if local.is_negs && strcontains(_, "/zones/")]) > 0 ? true : false
  alb_balancing_mode = local.is_gnegs ? null : local.is_negs ? "RATE" : "UTILIZATION"
  backend = {
    capacity_scaler              = local.is_tcp ? 0 : null
    balancing_mode               = local.is_tcp ? "CONNECTION" : local.alb_balancing_mode
    max_connections              = local.is_tcp && local.is_internal ? 0 : null
    max_connections_per_endpoint = 0
    max_connections_per_instance = 0
    max_rate                     = 0
    max_rate_per_endpoint        = 42
    max_rate_per_instance        = 0
    max_utilization              = 0
  }
  is_classic                      = coalesce(var.classic, false)
  is_application                  = startswith(local.protocol, "HTTP") ? true : false
  bucket                          = var.bucket != null && local.is_application && !local.is_regional && !local.is_internal ? var.bucket : null
  is_bucket                       = local.bucket != null ? true : false
  create_bucket                   = local.bucket != null ? lookup(local.bucket, "create", false) : false
  is_service                      = !local.is_bucket ? true : false
  load_balancing_scheme           = local.is_application && !local.is_classic ? "${local.type}_MANAGED" : local.type
  locality_lb_policy              = local.is_application && !local.is_classic ? upper(coalesce(var.locality_lb_policy, "ROUND_ROBIN")) : ""
  session_affinity                = local.is_tcp ? trimspace(coalesce(var.session_affinity, "NONE")) : null
  connection_draining_timeout_sec = coalesce(var.connection_draining_timeout_sec, 300)
  timeout_sec                     = local.is_tcp ? null : coalesce(var.timeout, 30)
  security_policy                 = local.is_application && var.security_policy != null ? lower(trimspace(var.security_policy)) : null
  uses_iap                        = var.iap != null && local.is_service ? true : false
  iap = local.uses_iap ? {
    create              = lookup(var.iap, "create", local.create)
    name                = lookup(var.iap, "name", "iap-${local.name}")
    application_title   = lookup(var.iap, "application_title", coalesce(local.description, local.name))
    support_email       = lookup(var.iap, "support_email", "nobody@nowhere.net")
    display_name        = lookup(var.iap, "display_name", local.name)
    web_backend_service = local.name
    role                = "roles/iap.httpsResourceAccessor"
    members             = toset(lookup(var.iap, "members", []))
  } : null
}

# IAP Brand
resource "google_iap_brand" "default" {
  count             = local.uses_iap ? 1 : 0
  project           = local.project
  application_title = lookup(local.iap, "application_title", null)
  support_email     = lookup(local.iap, "support_email", null)
}

# IAP Client
resource "google_iap_client" "default" {
  count        = local.uses_iap ? 1 : 0
  display_name = lookup(local.iap, "display_name", null)
  brand        = local.uses_iap ? one(google_iap_brand.default).name : null
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
  dynamic "iap" {
    for_each = local.uses_iap ? [true] : []
    content {
      enabled              = true
      oauth2_client_id     = one(google_iap_client.default).client_id
      oauth2_client_secret = one(google_iap_client.default).secret
    }
  }
  depends_on = [null_resource.backend_service]
  region     = local.region
  network    = local.is_tcp ? null : local.network
}

# Global Backend Service
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
  security_policy                 = local.security_policy
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

# IAP IAM Binding
resource "google_iap_web_backend_service_iam_binding" "default" {
  count               = local.create && local.uses_iap ? 1 : 0
  project             = local.project
  web_backend_service = local.is_regional ? one(google_compute_region_backend_service.default).name : one(google_compute_backend_service.default).name
  role                = lookup(local.iap, "role", null)
  members             = lookup(local.iap, "members", null)
}
