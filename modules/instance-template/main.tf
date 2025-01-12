resource "random_string" "name_prefix" {
  count   = var.name_prefix == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix   = "https://www.googleapis.com/compute/v1"
  create       = coalesce(var.create, true)
  project      = lower(trimspace(coalesce(var.project_id, var.project)))
  name_prefix  = lower(trimspace(var.name_prefix != null ? var.name_prefix : "template-${one(random_string.name_prefix).result}"))
  region       = lower(trimspace(var.region))
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  network = coalesce(
    startswith(var.network, "projects/") ? var.network : null,
    startswith(var.network, local.api_prefix) ? replace(var.network, local.api_prefix, "") : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )
  subnetwork = coalesce(
    startswith(var.subnetwork, "projects/", ) ? var.subnetwork : null,
    startswith(var.subnetwork, local.api_prefix) ? replace(var.subnetwork, local.api_prefix, "") : null,
    "projects/${local.host_project}/regions/${local.region}/subnetworks/${var.subnetwork}",
  )
  base_instance_name = try(coalesce(var.base_instance_name, var.name_prefix), null)
  version_name       = "${local.name_prefix}-0"
  machine_type       = lower(trimspace(coalesce(var.machine_type, "e2-micro")))
  startup_script     = var.startup_script
  can_ip_forward     = coalesce(var.can_ip_forward, false)
  os_project         = lower(trimspace(coalesce(var.os_project, "debian-cloud")))
  os                 = lower(trimspace(coalesce(var.os, "debian-12")))
  disk = {
    source_image = coalesce(var.disk.source_image, "${local.os_project}/${local.os}")
    boot         = coalesce(var.disk.boot, true)
    auto_delete  = coalesce(var.disk.auto_delete, true)
    type         = coalesce(var.disk.type, "pd-standard")
    size_gb      = coalesce(var.disk.size_gb, 10)
    interface    = coalesce(var.disk.interface, "SCSI")
    mode         = coalesce(var.disk.mode, "READ_WRITE")
    labels       = coalesce(var.disk.labels, {})
  }
  service_account = {
    email  = var.service_account_email
    scopes = coalescelist(var.service_account_scopes, ["https://www.googleapis.com/auth/cloud-platform"])
  }
  tags     = [for tag in coalesce(var.network_tags, var.tags, []) : lower(trimspace(tag))]
  metadata = coalesce(var.metadata, { enable-osconfig = "true" })
}

# Instance Template
resource "null_resource" "instance_template" {
  count = local.create ? 1 : 0
}
resource "google_compute_instance_template" "default" {
  count                   = local.create ? 1 : 0
  project                 = local.project
  region                  = local.region
  name_prefix             = local.name_prefix
  machine_type            = local.machine_type
  can_ip_forward          = local.can_ip_forward
  metadata                = local.metadata
  metadata_startup_script = local.startup_script
  tags                    = local.tags
  disk {
    auto_delete           = local.disk.auto_delete
    boot                  = local.disk.boot
    disk_type             = local.disk.type
    disk_size_gb          = local.disk.size_gb
    interface             = local.disk.interface
    mode                  = local.disk.mode
    provisioned_iops      = 0
    resource_manager_tags = {}
    resource_policies     = []
    source_image          = local.disk.source_image
    source_snapshot       = null
    type                  = "PERSISTENT"
  }
  network_interface {
    network            = local.network
    queue_count        = 0
    subnetwork         = local.subnetwork
    subnetwork_project = local.project
  }
  scheduling {
    automatic_restart           = true
    instance_termination_action = null
    min_node_cpus               = 0
    on_host_maintenance         = "MIGRATE"
    preemptible                 = false
    provisioning_model          = "STANDARD"
  }
  service_account {
    email  = local.service_account.email
    scopes = local.service_account.scopes
  }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }
  depends_on = [null_resource.instance_template]
}

