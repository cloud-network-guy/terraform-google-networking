provider "google" {
  project = local.project
  region  = local.region
}

locals {
  create         = coalesce(var.create, true)
  project        = lower(trimspace(coalesce(var.project_id, var.project)))
  host_project   = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  region         = var.region != null ? lower(trimspace(var.region)) : "global"
  is_global      = local.region == "global" ? true : false
  is_regional    = !local.is_global
  name           = lower(trimspace(coalesce(var.name, "psc-endpoint-${local.region}-${local.target_name}")))
  description    = trimspace(coalesce(var.description, "PSC to ${local.target}"))
  target_project = lower(trimspace(coalesce(var.target_project, local.project)))
  target_region  = var.target != null ? lower(element(split("/", var.target), 3)) : lower(trimspace(coalesce(var.target_region, var.region)))
  target_name    = var.target != null ? lower(element(split("/", var.target), 5)) : null
  target = trimspace(coalesce(
    var.target,
    var.target_id,
    "projects/${local.target_project}/regions/${local.target_region}/serviceAttachments/${local.target_name}"
  ))
  network             = coalesce(var.network, "default")
  subnetwork          = coalesce(var.subnetwork, "default")
  set_null_subnetwork = var.set_null_subnetwork
  global_access       = var.global_access
}

module "psc-endpoint" {
  source              = "../modules/forwarding-rule"
  project             = local.project
  create              = local.create
  name                = local.name
  region              = local.is_regional ? local.region : null
  address_name        = local.name
  address_description = local.description
  target              = local.target
  host_project        = local.host_project
  network             = local.network
  subnetwork          = local.subnetwork
  set_null_subnetwork = local.set_null_subnetwork
  global_access       = local.global_access
}

