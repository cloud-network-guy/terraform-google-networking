resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  is_psc       = var.target != null ? strcontains(var.target, "/serviceAttachments/") ? true : false : false
  is_redirect  = false
  api_prefix   = "https://www.googleapis.com/compute/v1"
  create       = coalesce(var.create, true)
  project      = lower(trimspace(coalesce(var.project_id, var.project)))
  name         = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description  = var.description != null ? trimspace(var.description) : null
  is_regional  = var.region != null ? true : false
  region       = local.is_regional ? var.region : "global"
  type         = var.type == "PSC" ? var.type : upper(coalesce(var.type, "INTERNAL"))
  is_internal  = local.type == "INTERNAL" || local.subnetwork != null ? true : false
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  network = coalesce(
    startswith(var.network, local.api_prefix) ? var.network : null,
    startswith(var.network, "projects/") ? "${local.api_prefix}/${var.network}" : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )
  subnetwork = coalesce(
    startswith(var.subnetwork, local.api_prefix) ? var.subnetwork : null,
    startswith(var.subnetwork, "projects/", ) ? "${local.api_prefix}/${var.subnetwork}" : null,
    "projects/${local.host_project}/regions/${local.region}/subnetworks/${var.subnetwork}",
  )
  network_tier        = local.is_internal ? null : upper(coalesce(var.network_tier, local.is_application_lb ? "PREMIUM" : "STANDARD"))
  address             = var.address != null ? trimspace(var.address) : null
  address_type        = local.is_internal ? "INTERNAL" : "EXTERNAL"
  address_purpose     = local.is_psc ? "GCE_ENDPOINT" : local.is_internal && local.is_redirect ? "SHARED_LOADBALANCER_VIP" : null
  address_name        = lower(trimspace(coalesce(var.address_name, local.name)))
  address_description = var.address_description != null ? trimspace(var.address_description) : null
  address_index_key   = local.is_regional ? "${local.project}/${local.region}/${local.address_name}" : "${local.project}/${local.address_name}"
  ip_version          = null
}

# Work-around for scenarios where PSC Consumer Endpoint IP changes
resource "null_resource" "ip_addresses" {
  count = local.create && local.is_psc ? 1 : 0
}

# Regional IP Address
resource "google_compute_address" "default" {
  count              = local.create && local.is_regional ? 1 : 0
  address            = local.address
  address_type       = local.address_type
  description        = local.address_description
  ip_version         = local.ip_version
  ipv6_endpoint_type = null
  name               = local.address_name
  network_tier       = local.network_tier
  prefix_length      = local.is_regional ? 0 : null
  project            = local.project
  purpose            = local.address_purpose
  region             = local.region
  subnetwork         = local.is_regional && local.is_internal ? local.subnetwork : null
  depends_on         = [null_resource.ip_addresses]
}

# Global IP address
resource "google_compute_global_address" "default" {
  count         = local.create && !local.is_regional ? 1 : 0
  address       = local.address
  address_type  = local.address_type
  description   = local.address_description
  ip_version    = local.ip_version
  name          = local.address_name
  network       = local.is_internal ? local.network : null
  prefix_length = 0
  purpose       = local.address_purpose
}

#allow_global_access     = local.is_psc ? null : local.is_internal ? coalesce(var.global_access, false) : null
locals {
  port                    = var.port
  ports                   = coalesce(var.ports, compact([local.port]))
  port_range              = var.port_range
  target                  = var.target
  backend_service         = var.backend_service != null ? trimspace(var.backend_service) : null
  is_application_lb       = false # TODO
  is_classic              = false # TODO
  protocol                = upper(coalesce(var.protocol, length(local.ports) > 0 || local.all_ports || local.is_psc ? "TCP" : "HTTP"))
  all_ports               = coalesce(var.all_ports, false)
  ip_protocol             = local.is_psc || local.protocol == "HTTP" ? null : local.protocol
  allow_global_access     = local.is_internal && !local.is_psc ? coalesce(var.global_access, false) : null
  allow_psc_global_access = local.is_psc ? coalesce(var.global_access, false) : null
  load_balancing_scheme   = local.is_psc ? "" : local.is_application_lb && !local.is_classic ? "${local.type}_MANAGED" : local.type
  ip_address              = local.create && local.is_psc && local.is_regional ? one(google_compute_address.default).self_link : null
  labels                  = { for k, v in coalesce(var.labels, {}) : k => lower(replace(v, " ", "_")) }
  is_mirroring_collector  = false # TODO
  source_ip_ranges        = []    # TODO
}

# Regional Forwarding Rule
resource "google_compute_forwarding_rule" "default" {
  count                   = local.create && local.is_regional ? 1 : 0
  all_ports               = local.all_ports
  allow_global_access     = local.allow_global_access
  allow_psc_global_access = local.allow_psc_global_access
  backend_service         = local.backend_service
  base_forwarding_rule    = null
  description             = local.description
  ip_address              = local.ip_address
  ip_protocol             = local.ip_protocol
  ip_version              = local.ip_version
  is_mirroring_collector  = local.is_mirroring_collector
  labels                  = local.labels
  load_balancing_scheme   = local.load_balancing_scheme
  name                    = local.name
  network                 = local.network
  network_tier            = local.is_psc ? null : local.network_tier
  port_range              = local.port_range
  ports                   = local.ports
  project                 = local.project
  recreate_closed_psc     = local.is_psc ? false : null
  region                  = local.region
  service_label           = null
  service_name            = null
  source_ip_ranges        = local.source_ip_ranges
  subnetwork              = local.is_internal && !local.is_psc ? local.subnetwork : null
  target                  = local.target
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  count                 = local.create && !local.is_regional ? 1 : 0
  base_forwarding_rule  = null
  description           = local.description
  ip_address            = local.ip_address
  ip_protocol           = local.ip_protocol
  ip_version            = local.ip_version
  labels                = local.labels
  load_balancing_scheme = local.load_balancing_scheme
  name                  = local.name
  network               = local.network
  port_range            = local.port_range
  project               = local.project
  source_ip_ranges      = local.source_ip_ranges
  subnetwork            = local.subnetwork
  target                = local.target
}