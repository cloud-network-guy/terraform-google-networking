resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix          = "https://www.googleapis.com/compute/v1"
  create              = coalesce(var.create, true)
  project             = lower(trimspace(coalesce(var.project_id, var.project)))
  name                = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description         = var.description != null ? trimspace(var.description) : null
  is_regional         = var.region != null ? true : false
  region              = local.is_regional ? var.region : "global"
  port                = coalesce(var.port, 80)
  host                = var.host != null ? trimspace(var.host) : null
  proxy_header        = coalesce(var.proxy_header, "NONE")
  logging             = coalesce(var.logging, false)
  healthy_threshold   = coalesce(var.healthy_threshold, 2)
  unhealthy_threshold = coalesce(var.unhealthy_threshold, 2)
  check_interval_sec  = coalesce(var.interval, 10)
  timeout_sec         = coalesce(var.timeout, 5)
  protocol            = upper(coalesce(var.protocol, var.request_path != null || var.response != null ? "HTTP" : "TCP"))
  request_path        = startswith(local.protocol, "HTTP") ? coalesce(var.request_path, "/") : null
  response            = startswith(local.protocol, "HTTP") ? var.response : null
  is_legacy           = coalesce(var.legacy, false)
  is_tcp              = local.protocol == "TCP" ? true : false
  is_http             = local.protocol == "HTTP" ? true : false
  is_https            = local.protocol == "HTTPS" ? true : false
  is_ssl              = local.protocol == "SSL" ? true : false
  index_key           = local.is_regional ? "${local.project}/${local.region}/${local.name}" : "${local.project}/${local.name}"
}

resource "null_resource" "healthcheck" {
  count = local.create ? 1 : 0
}

# Regional Health Check
resource "google_compute_region_health_check" "default" {
  count       = local.create && local.is_regional && !local.is_legacy ? 1 : 0
  project     = local.project
  name        = local.name
  description = local.description
  region      = local.region
  dynamic "tcp_health_check" {
    for_each = local.is_tcp ? [true] : []
    content {
      port         = local.port
      proxy_header = local.proxy_header
    }
  }
  dynamic "http_health_check" {
    for_each = local.is_http ? [true] : []
    content {
      port         = local.port
      host         = local.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "https_health_check" {
    for_each = local.is_https ? [true] : []
    content {
      port         = local.port
      host         = local.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = local.is_ssl ? [true] : []
    content {
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  check_interval_sec  = local.check_interval_sec
  timeout_sec         = local.timeout_sec
  healthy_threshold   = local.healthy_threshold
  unhealthy_threshold = local.unhealthy_threshold
  log_config {
    enable = local.logging
  }
  depends_on = [null_resource.healthcheck]
}

# Global Health Check
resource "google_compute_health_check" "default" {
  count       = local.create && !local.is_regional && !local.is_legacy ? 1 : 0
  project     = local.project
  name        = local.name
  description = local.description
  dynamic "tcp_health_check" {
    for_each = local.is_tcp ? [true] : []
    content {
      port         = local.port
      proxy_header = local.proxy_header
    }
  }
  dynamic "http_health_check" {
    for_each = local.is_http ? [true] : []
    content {
      port         = local.port
      host         = local.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "https_health_check" {
    for_each = local.is_https ? [true] : []
    content {
      port         = local.port
      host         = local.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = local.is_ssl ? [true] : []
    content {
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  check_interval_sec  = local.check_interval_sec
  timeout_sec         = local.timeout_sec
  healthy_threshold   = local.healthy_threshold
  unhealthy_threshold = local.unhealthy_threshold
  log_config {
    enable = local.logging
  }
  depends_on = [null_resource.healthcheck]
}


# Legacy HTTP Health Check
resource "google_compute_http_health_check" "default" {
  count              = local.create && local.is_legacy && local.is_http ? 1 : 0
  project            = local.project
  name               = local.name
  description        = local.description
  port               = local.port
  check_interval_sec = local.check_interval_sec
  timeout_sec        = local.timeout_sec
  depends_on         = [null_resource.healthcheck]
}

# Legacy HTTPS Health Check
resource "google_compute_https_health_check" "default" {
  count              = local.create && local.is_legacy && local.is_https ? 1 : 0
  project            = local.project
  name               = local.name
  description        = local.description
  port               = local.port
  check_interval_sec = local.check_interval_sec
  timeout_sec        = local.timeout_sec
  depends_on         = [null_resource.healthcheck]
}
