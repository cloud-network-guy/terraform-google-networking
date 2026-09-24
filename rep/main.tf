locals {
  create              = coalesce(var.create, true)
  api_prefix          = "https://www.googleapis.com/compute/v1"
  project             = lower(trimspace(coalesce(var.project_id, var.project)))
  host_project        = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  region              = var.region != null ? lower(trimspace(var.region)) : "global"
  is_global           = local.region == "global"
  is_regional         = !local.is_global
  name                = lower(trimspace(coalesce(var.name, "rep-${local.region}")))
  description         = trimspace(coalesce(var.description, "REP to ${local.target_google_api}"))
  address_name        = trimspace(coalesce(var.address_name, local.name))
  address_description = trimspace(coalesce(var.address_description, local.description))
  network = lower(trimspace(coalesce(
    startswith(var.network, local.api_prefix) ? var.network : null,
    startswith(var.network, "projects/") ? "${local.api_prefix}/${var.network}" : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )))
  subnetwork = lower(trimspace(coalesce(
    startswith(var.subnetwork, local.api_prefix) ? var.subnetwork : null,
    startswith(var.subnetwork, "projects/", ) ? "${local.api_prefix}/${var.subnetwork}" : null,
    "projects/${local.host_project}/regions/${local.region}/subnetworks/${var.subnetwork}",
  )))
  create_static_ip  = var.create_static_ip
  address           = var.address
  target_google_api = trimspace(var.target_google_api)
  labels            = { for k, v in coalesce(var.labels, {}) : k => lower(replace(v, " ", "_")) }
  address_labels    = var.set_address_labels ? local.labels : null
}

resource "null_resource" "regional_endpoint" {
  for_each = toset(local.create ? ["${local.region}/${local.name}"] : [])
}
resource "google_compute_address" "default" {
  count        = local.create && local.create_static_ip ? 1 : 0
  project      = local.project
  name         = local.address_name
  region       = local.region
  description  = local.address_description
  subnetwork   = local.subnetwork
  address      = local.address
  labels       = local.address_labels
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  depends_on   = [null_resource.regional_endpoint]
}

resource "google_network_connectivity_regional_endpoint" "default" {
  project           = local.project
  name              = local.name
  location          = local.region
  description       = local.description
  labels            = local.labels
  target_google_api = local.target_google_api
  access_type       = local.is_regional ? "REGIONAL" : "GLOBAL"
  network           = local.network
  subnetwork        = local.subnetwork
  address           = local.create_static_ip ? one(google_compute_address.default).id : var.address
  lifecycle {
  }
}
