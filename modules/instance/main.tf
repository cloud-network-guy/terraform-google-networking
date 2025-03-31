resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix   = "https://www.googleapis.com/compute/v1"
  create       = coalesce(var.create, true)
  project      = lower(trimspace(coalesce(var.project_id, var.project)))
  name         = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description  = var.description != null ? trimspace(var.description) : null
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  network = trimspace(coalesce(
    startswith(var.network, "${local.api_prefix}/projects/") ? var.network : null,
    startswith(var.network, "projects/") ? "${local.api_prefix}/${var.network}" : null,
    "${local.api_prefix}/projects/${local.project}/global/networks/${var.network}"
  ))
  subnetwork = trimspace(coalesce(
    startswith(var.subnetwork, local.api_prefix) ? var.subnetwork : null,
    startswith(var.subnetwork, "projects/", ) ? "${local.api_prefix}/${var.subnetwork}" : null,
    "${local.api_prefix}/projects/${local.host_project}/regions/${local.region}/subnetworks/${var.subnetwork}",
  ))
  machine_type   = lower(trimspace(coalesce(var.machine_type, "e2-micro")))
  can_ip_forward = coalesce(var.can_ip_forward, false)
  labels = coalesce(
    var.labels != null ? { for k, v in var.labels : k => lower(replace(v, " ", "_")) } : null,
    {
      os           = coalesce(local.os, split("/", local.boot_disk.image)[1])
      image        = substr(replace(local.boot_disk.image, "/", "-"), 0, 63)
      machine_type = local.machine_type
    }
  )
  metadata = merge(
    var.metadata,
    { startup-script = var.startup_script }
  )
  delete_protection         = coalesce(var.delete_protection, false)
  allow_stopping_for_update = coalesce(var.allow_stopping_for_update, true)
  os                        = lower(trimspace(coalesce(var.os, "debian-12")))
  os_projects = {
    debian     = "debian-cloud"
    ubuntu-pro = "ubutnu-os-pro-cloud"
    ubuntu     = "ubuntu-os-cloud"
    windows    = "window-cloud"
    checkpoint = "checkpoint-public"
    sql        = "windows-sql-cloud"
    fedora     = "fedora-coreos-cloud"
    rocky      = "rocky-linux-cloud"
    rhel       = "rhel-cloud"
    opensuse   = "opensuse-cloud"
    centos     = "centos-cloud"
    cos        = "cos-cloud"
    sles       = "suse-sap-cloud"
  }
  os_project = lower(trimspace(coalesce(
    var.os_project,
    one([for k, v in local.os_projects : v if startswith(local.os, k)])
  )))
  tags = [for tag in coalesce(var.network_tags, var.tags, []) : lower(trimspace(tag))]
  boot_disk = {
    type  = coalesce(lookup(var.disk, "type", null), "pd-standard")
    size  = coalesce(lookup(var.disk, "size_gb", null), lookup(var.disk, "size", null), 10)
    image = coalesce(lookup(var.disk, "image", null), "${local.os_project}/${local.os}")
  }
  service_account = {
    email  = var.service_account_email
    scopes = coalescelist(var.service_account_scopes, ["https://www.googleapis.com/auth/cloud-platform"])
  }
  network_interfaces = [
    {
      network            = local.network
      queue_count        = 0
      subnetwork         = local.subnetwork
      subnetwork_project = local.host_project
    }
  ]
  nat_ips = []
  _region = lower(trimspace(coalesce(
    var.zone != null ? trimsuffix(var.zone, substr(var.zone, -2, 2)) : null,
    var.region,
    "us-central1"
  )))
}

# Get a list of available zones, if required
data "google_compute_zones" "available" {
  count   = 1
  project = local.project
  region  = local._region
}

locals {
  zone = lower(trimspace(coalesce(
    var.zone,
    element(one(data.google_compute_zones.available).names, 1)
  )))
  region = trimsuffix(local.zone, substr(local.zone, -2, 2))
}

/*
resource "google_compute_address" "instance_nat_ips" {
  for_each      = { for i, v in local.instance_nat_ips : v.index_key => v }
  project       = local.project
  name          = local.name
  description   = local.description
  region        = local.region
  purpose       = null
  address_type  = "EXTERNAL"
  network_tier  = "PREMIUM"
  prefix_length = 0
  address       = local.address
}
*/


resource "google_compute_instance" "default" {
  count               = local.create ? 1 : 0
  name                = local.name
  description         = local.description
  zone                = local.zone
  project             = local.project
  machine_type        = local.machine_type
  can_ip_forward      = local.can_ip_forward
  deletion_protection = local.delete_protection
  tags                = local.tags
  labels              = local.labels
  metadata            = local.metadata
  boot_disk {
    initialize_params {
      type  = local.boot_disk.type
      size  = local.boot_disk.size
      image = local.boot_disk.image
    }
  }
  dynamic "network_interface" {
    for_each = local.network_interfaces
    content {
      network            = network_interface.value.network
      subnetwork_project = network_interface.value.subnetwork_project
      subnetwork         = network_interface.value.subnetwork
      dynamic "access_config" {
        for_each = local.nat_ips
        content {
          nat_ip = local.nat_ips[0].address
        }
      }
    }
  }
  service_account {
    email  = local.service_account.email
    scopes = local.service_account.scopes
  }
  allow_stopping_for_update = local.allow_stopping_for_update
}

