
# If no name provided, generate a random one
resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix   = "https://www.googleapis.com/compute/v1"
    create              = coalesce(var.create, true)
  project             = lower(trimspace(coalesce(var.project_id, var.project)))
  name                = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  region       = local.is_regional ? lower(trimspace(var.region)) : trimsuffix(local.zone, substr(local.zone, -2, 2))
  is_zonal     = var.zone != null ? true : false
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  description  = trimspace(coalesce(var.description, "Managed by Terraform"))
  is_regional  = var.region != null && var.region != "global" && !local.is_zonal ? true : false
  is_global    = !local.is_regional && !local.is_zonal ? true : false
  zone         = local.is_zonal ? lower(trimspace(var.zone)) : null
  is_psc       = var.psc_target != null ? true : false
  default_port = try(coalesce(var.default_port, var.port), null)
  ip_address   = var.ip_address != null ? trimspace(var.ip_address) : null
  fqdn         = var.fqdn != null ? trimspace(var.fqdn) : null
  endpoints = [for e in coalesce(var.endpoints, []) :
    merge(e, {
      create     = lookup(e, "create", local.create)
      project    = local.project
      ip_address = lookup(e, "ip_address", local.ip_address)
      fqdn       = lookup(e, "fqdn", local.fqdn)
      port       = lookup(e, "port", local.default_port)
    })
  ]
  gneg_endpoints = [for i, v in local.endpoints : v if local.is_global && !local.is_psc]
  rneg_endpoints = [for i, v in local.endpoints : v if local.is_regional]
  zneg_endpoints = [for i, v in local.endpoints : v if local.is_zonal]
  network_endpoint_type = coalesce(
    local.is_psc ? "PRIVATE_SERVICE_CONNECT" : null,
    local.is_zonal ? local.default_port == null ? "GCE_VM_IP" : "GCE_VM_IP_PORT" : null,
    local.is_regional ? "SERVERLESS" : null,
    length([for e in local.endpoints : e if e.fqdn != null]) > 0 ? "INTERNET_FQDN_PORT" : null,
    length([for e in local.endpoints : e if e.ip_address != null]) > 0 ? "INTERNET_IP_PORT" : null,
    "UNKNOWN"
  )
  psc_target_service = local.is_psc ? lower(trimspace(var.psc_target)) : null
  cloud_run_service  = local.is_regional && var.cloud_run_service != null ? lower(trimspace(var.cloud_run_service)) : null
  network = coalesce(
    startswith(var.network, "projects/") ? var.network : null,
    startswith(var.network, local.api_prefix) ? var.network : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )
  subnetwork = trimspace(coalesce(
    startswith(var.subnetwork, local.api_prefix) ? var.subnetwork : null,
    startswith(var.subnetwork, "projects/", ) ? "${local.api_prefix}/${var.subnetwork}" : null,
    "${local.api_prefix}/projects/${local.host_project}/regions/${local.region}/subnetworks/${var.subnetwork}",
  ))
}

resource "null_resource" "gnegs" {
  count = local.create && local.is_global && !local.is_psc ? 1 : 0
}
resource "google_compute_global_network_endpoint_group" "default" {
  count                 = local.create && local.is_global && !local.is_psc ? 1 : 0
  project               = local.project
  name                  = local.name
  network_endpoint_type = local.network_endpoint_type
  default_port          = local.default_port
  depends_on            = [null_resource.gnegs]
}

# Global Network Endpoints
locals {
}
resource "google_compute_global_network_endpoint" "default" {
  for_each                      = { for i, v in local.gneg_endpoints : i => v if v.create }
  project                       = each.value.project
  fqdn                          = each.value.fqdn
  ip_address                    = each.value.ip_address
  port                          = coalesce(each.value.port, 443) # We're going via Internet, so assume HTTPS
  global_network_endpoint_group = local.create ? one(google_compute_global_network_endpoint_group.default).id : null
}

# Regional Network Endpoint Groups
resource "null_resource" "rnegs" {
  count = local.create && local.is_regional ? 1 : 0
}
resource "google_compute_region_network_endpoint_group" "default" {
  count                 = local.create && local.is_regional ? 1 : 0
  project               = local.project
  name                  = local.name
  network_endpoint_type = local.network_endpoint_type
  region                = local.region
  psc_target_service    = local.psc_target_service
  network               = local.network
  subnetwork            = local.subnetwork
  dynamic "cloud_run" {
    for_each = local.cloud_run_service != null ? [true] : []
    content {
      service = local.cloud_run_service
    }
  }
  depends_on = [null_resource.rnegs]
}
resource "google_compute_region_network_endpoint" "default" {
  for_each                      = { for i, v in local.rneg_endpoints : i => v if v.create }
  project                       = each.value.project
  fqdn                          = each.value.fqdn
  ip_address                    = each.value.ip_address
  port                          = each.value.port
  region                        = local.region
  region_network_endpoint_group = one(google_compute_region_network_endpoint_group.default).id
  depends_on                    = [null_resource.rnegs]
}

# Zonal Network Endpoint Groups
resource "null_resource" "znegs" {
  count = local.create && local.is_zonal ? 1 : 0
}
resource "google_compute_network_endpoint_group" "default" {
  count                 = local.create && local.is_zonal ? 1 : 0
  project               = local.project
  name                  = local.name
  network_endpoint_type = local.network_endpoint_type
  zone                  = local.zone
  network               = local.network
  subnetwork            = local.subnetwork
  default_port          = local.default_port
  depends_on            = [null_resource.znegs]
}

# Zonal Network Endpoints
resource "google_compute_network_endpoint" "default" {
  for_each               = { for i, v in local.zneg_endpoints : i => v if v.create }
  project                = each.value.project
  network_endpoint_group = one(google_compute_network_endpoint_group.default).id
  zone                   = local.zone
  instance               = each.value.instance
  ip_address             = each.value.ip_address
  port                   = coalesce(each.value.port, local.default_port, 80)
  depends_on             = [null_resource.znegs]
}
