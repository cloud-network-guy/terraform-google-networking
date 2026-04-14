provider "google" {
  project = local.project
  region  = local.region
}

locals {
  create            = coalesce(var.create, true)
  project           = trimspace(var.project_id)
  name              = coalesce(var.name, "psc-endpoint-${local.region}-${local.target_name}")
  description       = coalesce(var.description, "PSC to ${local.target}")
  target_name       = var.target_id != null ? lower(element(split("/", var.target_id), 5)) : var.target_name
  target_region     = var.target_id != null ? lower(element(split("/", var.target_id), 3)) : coalesce(var.target_region, var.region)
  target_project_id = coalesce(var.target_project_id, var.project_id)
  target            = coalesce(var.target_id, "projects/${local.target_project_id}/regions/${local.target_region}/serviceAttachments/${local.target_name}")
  region            = coalesce(var.region, local.target_region)
}

module "psc-endpoint" {
  source              = "../modules/forwarding-rule"
  project             = local.project
  create              = local.create
  name                = local.name
  region              = local.region
  address_name        = local.name
  address_description = local.description
  target              = local.target
  host_project_id     = var.network_project_id
  network             = var.network_name
  subnetwork          = var.subnet_name
  set_null_subnetwork = var.set_null_subnetwork
  global_access       = var.global_access
}
