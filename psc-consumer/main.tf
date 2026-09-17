locals {
  create         = coalesce(var.create, true)
  project        = lower(trimspace(coalesce(var.project_id, var.project)))
  host_project   = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  region         = var.region != null ? lower(trimspace(var.region)) : "global"
  is_global      = local.region == "global" ? true : false
  is_regional    = !local.is_global
  target_project = lower(trimspace(coalesce(var.target_project, local.project)))
  target_region  = var.target != null && strcontains(var.target, "/") ? lower(element(split("/", var.target), 3)) : lower(trimspace(coalesce(var.target_region, var.region)))
  target_name    = var.target != null && strcontains(var.target, "/") ? lower(element(split("/", var.target), 5)) : lower(trimspace(coalesce(var.target_name, var.name)))
  target = trimspace(coalesce(
    var.target,
    var.target_id,
    "projects/${local.target_project}/regions/${local.target_region}/serviceAttachments/${local.target_name}"
  ))
  is_rep              = strcontains(local.target, ".rep.")
  name                = lower(trimspace(coalesce(var.name, "psc-endpoint-${local.region}-${local.target_name}")))
  address_name        = trimspace(coalesce(var.address_name, local.name))
  description         = trimspace(coalesce(var.description, "${local.is_rep ? "REP" : "PSC"} to ${local.target}"))
  address_description = trimspace(coalesce(var.address_description, local.description))
  network             = coalesce(var.network, "default")
  subnetwork          = coalesce(var.subnetwork, "default")
  set_null_subnetwork = var.set_null_subnetwork
  global_access       = var.global_access
  create_static_ip    = var.create_static_ip
}

module "psc-endpoint" {
  source              = "../modules/forwarding-rule"
  project             = local.project
  create              = local.create && !local.is_rep
  name                = local.name
  region              = local.is_regional ? local.region : null
  address_name        = local.create_static_ip ? local.address_name : null
  address_description = local.create_static_ip ? local.address_description : null
  target              = local.target
  host_project        = local.host_project
  network             = local.network
  subnetwork          = local.subnetwork
  set_null_subnetwork = local.set_null_subnetwork
  global_access       = local.global_access
}

# Create a null resource as work-around for when region or name changes
resource "null_resource" "regional_endpoint" {
  for_each = toset(local.create && local.is_rep ? ["${local.region}/${local.name}"] : [])
}

resource "google_compute_address" "regional_endpoint" {
  count        = local.create && local.create_static_ip && local.is_rep ? 1 : 0
  project      = local.project
  name         = local.address_name
  description  = local.address_description
  region       = local.region
  subnetwork   = local.subnetwork
  address_type = "INTERNAL"
  depends_on   = [null_resource.regional_endpoint]
}

resource "google_network_connectivity_regional_endpoint" "regional_endpoint" {
  count             = local.create && local.is_rep ? 1 : 0
  project           = local.project
  name              = local.name
  location          = local.is_regional ? local.region : null
  target_google_api = local.target
  access_type       = local.global_access ? "GLOBAL" : "REGIONAL"
  address           = local.create_static_ip ? one(google_compute_address.regional_endpoint).id : null
  network           = local.network
  subnetwork        = local.subnetwork
  description       = local.description
}
