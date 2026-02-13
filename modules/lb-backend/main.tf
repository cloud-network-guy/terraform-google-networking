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
  name           = var.name #lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description    = var.description != null ? trimspace(var.description) : null
  region         = lower(trimspace(coalesce(var.region, "global")))
  is_regional    = local.region != "global" ? true : false
  is_global      = !local.is_regional
  type           = upper(trimspace(coalesce(var.type, "INTERNAL")))
  is_internal    = local.type == "INTERNAL" ? true : false
  protocol       = var.protocol != null ? upper(trimspace(var.protocol)) : "TCP"
  is_tcp         = local.protocol == "TCP" ? true : false
  is_psc         = local.is_application && local.is_regional && !local.is_internal ? true : false
  _health_checks = var.health_check != null ? [var.health_check] : compact(coalesce(var.health_checks, []))
  health_checks = local.is_gnegs || local.is_psc ? null : [for hc in local._health_checks :
    coalesce(
      startswith(hc, local.api_prefix) ? hc : null,
      startswith(hc, "projects/", ) ? "${local.api_prefix}/${hc}" : null,
      local.is_regional ? "${local.api_prefix}/projects/${local.project}/regions/${local.region}/healthChecks/${hc}" : null,
      "${local.api_prefix}/projects/${local.project}/global/healthChecks/${hc}"
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
  is_igs                      = length([for _ in local.groups : _ if strcontains(_, "/instanceGroups/")]) > 0 ? true : false
  is_negs                     = length([for _ in local.groups : _ if strcontains(_, "/networkEndpointGroups/")]) > 0 ? true : false
  is_gnegs                    = length([for _ in local.groups : _ if local.is_negs && strcontains(_, "/global/")]) > 0 ? true : false
  is_rnegs                    = length([for _ in local.groups : _ if local.is_negs && strcontains(_, "/regions/")]) > 0 ? true : false
  is_znegs                    = length([for _ in local.groups : _ if local.is_negs && strcontains(_, "/zones/")]) > 0 ? true : false
  balancing_mode              = var.balancing_mode != null ? upper(trimspace(coalesce(var.balancing_mode, "CONNECTION"))) : null
  alb_balancing_mode          = local.is_gnegs ? null : local.is_negs && !local.is_psc ? "RATE" : coalesce(local.balancing_mode, "UTILIZATION")
  use_connection_balancing    = local.is_tcp ? true : false
  use_rate_balancing          = local.alb_balancing_mode != null && local.alb_balancing_mode == "RATE" ? true : false
  use_utilization_balancing   = local.alb_balancing_mode != null && local.alb_balancing_mode == "UTILIZATION" ? true : false
  ip_address_selection_policy = var.ip_address_selection_policy != null ? upper(trimspace(var.ip_address_selection_policy)) : null
  backend = {
    capacity_scaler              = local.is_tcp ? 0 : local.is_managed ? coalesce(var.capacity_scaler, 1.0) : null
    balancing_mode               = local.use_connection_balancing ? "CONNECTION" : local.alb_balancing_mode
    max_connections              = local.use_connection_balancing && local.is_internal ? 0 : null
    max_connections_per_endpoint = local.use_connection_balancing ? coalesce(var.max_connections_per_endpoint, 0) : null
    max_connections_per_instance = local.use_connection_balancing ? coalesce(var.max_connections_per_instance, 0) : null
    max_rate                     = local.use_rate_balancing ? coalesce(var.max_rate, 1024) : null
    max_rate_per_endpoint        = local.use_rate_balancing ? coalesce(var.max_rate_per_endpoint, 0) : null
    max_rate_per_instance        = local.use_rate_balancing ? coalesce(var.max_rate_per_instance, 0) : null
    max_utilization              = local.use_utilization_balancing ? coalesce(var.max_utilization, 0) : null
  }
  is_classic                      = coalesce(var.classic, false)
  is_application                  = startswith(local.protocol, "HTTP") ? true : false
  port_name                       = local.is_igs && local.is_application && var.port_name != null ? trimspace(var.port_name) : null
  bucket                          = var.bucket != null && local.is_application && !local.is_regional && !local.is_internal ? var.bucket : null
  is_bucket                       = local.bucket != null ? true : false
  create_bucket                   = local.bucket != null ? lookup(local.bucket, "create", false) : false
  is_service                      = !local.is_bucket ? true : false
  load_balancing_scheme           = local.is_application && !local.is_classic ? "${local.type}_MANAGED" : local.type
  is_managed                      = endswith(local.load_balancing_scheme, "_MANAGED")
  locality_lb_policy              = local.is_application && !local.is_classic ? upper(coalesce(var.locality_lb_policy, "ROUND_ROBIN")) : ""
  session_affinity                = local.is_tcp ? trimspace(coalesce(var.session_affinity, "NONE")) : null
  connection_draining_timeout_sec = coalesce(var.connection_draining_timeout_sec, 300)
  timeout_sec                     = local.is_tcp ? null : coalesce(var.timeout, 30)
  security_policy                 = local.is_application && !local.is_internal && var.security_policy != null ? trimspace(var.security_policy) : null
  enable_cdn                      = var.cdn != null && local.is_application && !local.is_regional && !local.is_internal ? true : false
  cdn_cache_mode                  = local.enable_cdn ? upper(lookup(var.cdn, "cache_mode", "CACHE_ALL_STATIC")) : "NONE"
  cdn = local.enable_cdn ? {
    cache_mode      = local.cdn_cache_mode
    cdn_default_ttl = local.cdn_cache_mode == "CACHE_ALL_STATIC" ? 3600 : 0
    cdn_min_ttl     = local.cdn_cache_mode == "CACHE_ALL_STATIC" ? 60 : 0
    cdn_max_ttl     = local.cdn_cache_mode == "CACHE_ALL_STATIC" ? 14400 : 0
    cdn_client_ttl  = local.cdn_cache_mode == "CACHE_ALL_STATIC" ? 3600 : 0
  } : null
  uses_iap          = var.iap != null && local.is_service && local.is_application && local.is_global ? true : false
  iap_has_condition = local.uses_iap ? lookup(var.iap, "condition", null) != null ? true : false : null
  iap = {
    enabled = local.uses_iap ? coalesce(var.iap.enabled, local.create) : false
    role    = "roles/iap.httpsResourceAccessor"
    members = local.uses_iap ? toset(coalesce(var.iap.members, [])) : null
    condition = local.uses_iap ? {
      title       = coalesce(var.iap.condition.title, "IAP Condition for backend '${local.name}'")
      description = var.iap.condition.description
      expression  = var.iap.condition.expression
    } : null
  }
  custom_request_headers = var.custom_request_headers != null ? toset(var.custom_request_headers) : null
}

resource "null_resource" "backend_service" {
  count = local.create ? 1 : 0
}

# Regional Backend Service
resource "google_compute_region_backend_service" "default" {
  count                           = local.create && (local.is_regional && !local.is_psc) ? 1 : 0
  project                         = local.project
  name                            = local.name
  description                     = local.description
  protocol                        = local.protocol
  port_name                       = local.port_name
  load_balancing_scheme           = local.load_balancing_scheme
  locality_lb_policy              = local.locality_lb_policy
  session_affinity                = local.session_affinity
  health_checks                   = local.health_checks
  timeout_sec                     = local.timeout_sec
  connection_draining_timeout_sec = local.connection_draining_timeout_sec
  ip_address_selection_policy     = local.ip_address_selection_policy
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
      max_rate_per_instance        = local.backend.max_rate_per_instance
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
  network    = local.is_tcp || local.is_internal ? null : local.network
}

# Global Backend Service
resource "google_compute_backend_service" "default" {
  count                           = local.create && (local.is_global || local.is_psc) ? 1 : 0
  project                         = local.project
  name                            = local.name
  description                     = local.description
  protocol                        = local.protocol
  port_name                       = local.port_name
  load_balancing_scheme           = local.load_balancing_scheme
  locality_lb_policy              = local.locality_lb_policy
  session_affinity                = local.session_affinity
  health_checks                   = local.health_checks
  timeout_sec                     = local.timeout_sec
  connection_draining_timeout_sec = local.connection_draining_timeout_sec
  security_policy                 = local.security_policy
  ip_address_selection_policy     = local.ip_address_selection_policy
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
      max_rate_per_instance        = local.backend.max_rate_per_instance
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
  enable_cdn = local.enable_cdn
  dynamic "cdn_policy" {
    for_each = local.enable_cdn ? [true] : []
    content {
      cache_mode                   = lookup(local.cdn, "cache_mode", null)
      default_ttl                  = lookup(local.cdn, "default_ttl", null)
      client_ttl                   = lookup(local.cdn, "client_ttl", null)
      max_ttl                      = lookup(local.cdn, "max_ttl", null)
      signed_url_cache_max_age_sec = 3600
      negative_caching             = false
      cache_key_policy {
        include_host           = true
        include_protocol       = true
        include_query_string   = true
        query_string_blacklist = []
        query_string_whitelist = []
      }
    }
  }
  dynamic "iap" {
    for_each = local.uses_iap ? [true] : []
    content {
      enabled              = local.iap.enabled
      oauth2_client_id     = local.iap.enabled ? " " : null
      oauth2_client_secret = local.iap.enabled ? " " : null
    }
  }
  custom_request_headers = local.custom_request_headers
  depends_on             = [null_resource.backend_service]
}

# IAP Web Service IAM Binding
resource "google_iap_web_backend_service_iam_binding" "default" {
  count               = local.create && local.uses_iap && local.iap.enabled ? 1 : 0
  project             = local.project
  web_backend_service = "projects/${local.project}/iap_web/compute/services/${one(google_compute_backend_service.default).name}"
  role                = local.iap.role
  members             = local.iap.members
  dynamic "condition" {
    for_each = local.iap_has_condition ? [true] : []
    content {
      description = local.iap.condition.description
      expression  = local.iap.condition.expression
      title       = local.iap.condition.title
    }
  }
}

