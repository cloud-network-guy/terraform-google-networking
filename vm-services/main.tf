
locals {
  # Set object attributes
  instances = [for k, v in var.deployments :
    {
      create                 = coalesce(v.create, var.create, true)
      name                   = v.name
      region                 = coalesce(v.region, k)
      zone                   = v.zone
      network                = try(coalesce(v.network, var.network), null)
      host_project_id        = var.host_project_id
      subnetwork             = coalesce(v.subnetwork, "default")
      machine_type           = coalesce(v.machine_type, var.machine_type, "e2-small")
      startup_script         = coalesce(v.startup_script, var.startup_script, "")
      network_tags           = coalesce(v.network_tags, var.network_tags, [])
      service_account_email  = try(coalesce(v.service_account_email, var.service_account_email), null)
      service_account_scopes = coalesce(v.service_account_scopes, var.service_account_scopes)
      os                     = coalesce(v.os, var.os)
      os_project             = try(coalesce(v.os_project, var.os_project), null)
      disk_image             = try(coalesce(v.disk_image, var.disk_image), null)
      disk_type              = coalesce(v.disk_type, var.disk_type)
      disk_size              = coalesce(v.disk_size, var.disk_size)
      labels                 = var.labels
    }
  ]
  region_codes = {
    northamerica-northeast1 = "nane1"
    northamerica-northeast2 = "nane2"
    us-central1             = "usce1"
    us-east1                = "usea1"
    us-east4                = "usea4"
    us-east5                = "usea5"
    us-west1                = "uswe1"
    us-west2                = "uswe2"
    us-west3                = "uswe3"
    us-west4                = "uswe4"
    us-south1               = "usso1"
    europe-west1            = "euwe1"
    europe-west2            = "euwe2"
    europe-west3            = "euwe3"
    europe-west4            = "euwe4"
    australia-southeast1    = "ause1"
    australia-southeast2    = "ause2"
    asia-northeast1         = "asne1"
    asia-northeast2         = "asne2"
    asia-southeast1         = "asse1"
    asia-southeast2         = "asse2"
    asia-east1              = "asea1"
    asia-east2              = "asea2"
    asia-south1             = "asso1"
    asia-south2             = "asso2"
    southamerica-east1      = "saea1"
    me-central1             = "mece1"
  }
}

# Create the Instances
module "instance" {
  source          = "../modules/instance"
  for_each        = { for i, v in local.instances : coalesce(v.zone, v.region) => v if v.create }
  project_id      = var.project_id
  host_project_id = each.value.host_project_id
  name = lower(trimspace(coalesce(
    each.value.name,
    "${var.name_prefix}-${lookup(local.region_codes, each.value.region, "error")}"
  )))
  region                 = substr(each.value.region, -2, 1) != "-" ? each.value.region : null
  zone                   = each.value.zone
  service_account_email  = each.value.service_account_email
  service_account_scopes = each.value.service_account_scopes
  network                = each.value.network
  subnetwork             = each.value.subnetwork
  network_tags           = each.value.network_tags
  machine_type           = each.value.machine_type
  disk = {
    type    = each.value.disk_type
    size_gb = each.value.disk_size
  }
  os_project     = each.value.os_project
  os             = each.value.os
  labels         = each.value.labels
  startup_script = each.value.startup_script
}
