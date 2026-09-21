locals {
  create              = coalesce(var.create, true)
  project             = lower(trimspace(coalesce(var.project_id, var.project)))
  host_project        = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  region              = var.region != null ? lower(trimspace(var.region)) : "global"
  is_global           = local.region == "global"
  is_regional         = !local.is_global
  target              = trimspace(var.target)
  name                = lower(trimspace(coalesce(var.name, "rep-${local.region}-${local.target}")))
  description         = trimspace(coalesce(var.description, "REP to ${local.target}"))
  address_name        = trimspace(coalesce(var.address_name, local.name))
  address_description = trimspace(coalesce(var.address_description, local.description))
  network             = lower(trimspace("projects/${local.project}/global/networks/${var.network}"))
  subnetwork          = lower(trimspace("projects/${local.project}/regions/${local.region}/subnetworks/${var.subnetwork}"))
  create_static_ip    = var.create_static_ip
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
  address      = var.address
  labels       = var.labels
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  depends_on   = [null_resource.regional_endpoint]
}

resource "google_network_connectivity_regional_endpoint" "default" {
  project           = local.project
  name              = var.name
  location          = local.region
  description       = var.description
  labels            = var.labels
  target_google_api = var.target
  access_type       = local.is_regional ? "REGIONAL" : "GLOBAL"
  network           = local.network
  subnetwork        = local.subnetwork
  address           = var.create_static_ip ? one(google_compute_address.default).address : var.address
  #lifecycle {
  #}
}
