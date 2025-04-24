locals {
  api_prefix              = "https://www.googleapis.com/compute/v1"
  create                  = coalesce(var.create, true)
  project                 = lower(trimspace(coalesce(var.project_id, var.project)))
  region                  = trimspace(coalesce(var.region))
  host_project            = lower(trimspace(coalesce(var.network_project_id, var.host_project, local.project)))
  install_type            = coalesce(var.install_type, "Cluster")
  is_cluster              = local.install_type == "Cluster" ? true : false
  is_mig                  = local.install_type == "AutoScale" ? true : false
  is_gateway              = local.is_cluster || local.is_mig || length(regexall("Gateway", local.install_type)) > 0 ? true : false
  is_standalone           = local.is_cluster || local.is_mig ? false : true
  is_management           = length(regexall("Management", local.install_type)) > 0 ? true : false
  is_management_only      = startswith(local.install_type, "Management") ? true : false
  is_manual               = startswith(local.install_type, "Manual") ? true : false
  install_image           = local.is_standalone ? "single" : (local.is_mig ? "mig" : "cluster")
  install_code            = local.is_manual || local.is_management_only ? "" : "${local.install_image}-"
  name                    = coalesce(var.name, substr("chkp-${local.install_code}-${local.region}", 0, 16))
  generate_admin_password = local.create && var.admin_password == null ? true : false
  generate_sic_key        = local.create && var.sic_key == null ? true : false
  network_project_id      = coalesce(var.network_project_id, local.project)
  create_instance_groups  = coalesce(var.create_instance_groups, local.is_cluster ? true : false)
}


provider "google" {
  project = local.project
  region  = local.region
}

# If Admin password not provided, create random 16 character one
resource "random_string" "admin_password" {
  count   = local.generate_admin_password ? 1 : 0
  length  = 16
  special = false
}

# If SIC key not provided, create random 8 character one
resource "random_string" "sic_key" {
  count   = local.generate_sic_key ? 1 : 0
  length  = 8
  special = false
}

locals {
  instance_suffixes  = coalesce(var.instance_suffixes, local.is_cluster ? ["member-a", "member-b"] : ["gateway"])
  instance_zones     = coalesce(var.zones, ["b", "c"])
  nic0_address_names = local.is_cluster ? ["primary-cluster", "secondary-cluster"] : local.instance_suffixes
  address_names = {
    nic0 = local.is_gateway ? [for n in local.nic0_address_names : "${local.name}-${n}"] : [local.name]
    nic1 = local.is_gateway ? [for n in local.instance_suffixes : "${local.name}-${n}"] : ["${local.name}-2"]
  }
  # Create a list of objects for the instances so it's easier to iterate over
  instances = [for i, v in local.instance_suffixes : {
    name              = local.is_standalone ? local.name : "${local.name}-${v}"
    zone              = "${local.region}-${local.instance_zones[i]}"
    nic0_address_name = "${local.address_names["nic0"][i]}-address"
    nic1_address_name = "${local.address_names["nic1"][i]}-nic1-address"
    }
  ]
  create_nic0_external_ips = local.create ? coalesce(var.create_nic0_external_ips, true) : false
  create_nic1_external_ips = local.create ? coalesce(var.create_nic1_external_ips, true) : false
}

# Create External Addresses to assign to nic0
resource "google_compute_address" "nic0_external_ips" {
  count        = local.create_nic0_external_ips ? length(local.instances) : 0
  project      = local.project
  name         = local.instances[count.index].nic0_address_name
  region       = local.region
  address_type = "EXTERNAL"
}

# Create External Addresses to assign to nic1, if desired
resource "google_compute_address" "nic1_external_ips" {
  count        = local.create_nic1_external_ips ? length(local.instances) : 0
  project      = local.project
  name         = local.instances[count.index].nic1_address_name
  region       = local.region
  address_type = "EXTERNAL"
}

# For clusters, get status of the the primary and secondary addresses so we don't lose them after configuration
data "google_compute_address" "nic0_external_ips" {
  count      = local.is_cluster ? length(local.instances) : 0
  project    = local.project
  name       = local.instances[count.index].nic0_address_name
  region     = local.region
  depends_on = [google_compute_address.nic0_external_ips]
}

# Locals related to the instances
locals {
  machine_type     = coalesce(var.machine_type, "n1-standard-4")
  network_tags     = coalescelist(var.network_tags, local.is_gateway ? ["checkpoint-gateway"] : ["checkpoint-management"])
  labels           = coalesce(var.labels, {})
  disk_type        = coalesce(var.disk_type, "pd-ssd")
  disk_size        = coalesce(var.disk_size, 100)
  disk_auto_delete = coalesce(var.disk_auto_delete, true)
  service_account_scopes = coalescelist(
    var.service_account_scopes,
    concat(
      ["https://www.googleapis.com/auth/monitoring.write"],
      local.is_gateway ? ["https://www.googleapis.com/auth/compute", "https://www.googleapis.com/auth/cloudruntimeconfig"] : []
    )
  )
  software_version  = coalesce(var.software_version, "R81.10")
  software_code     = lower(replace(local.software_version, ".", ""))
  template_name     = local.is_cluster ? "${lower(local.install_type)}_tf" : "single_tf"
  license_type      = lower(coalesce(var.license_type, "BYOL"))
  checkpoint_prefix = "projects/checkpoint-public/global/images/check-point-${local.software_code}"
  image_type        = local.is_gateway ? "-gw" : ""
  image_prefix      = "${local.checkpoint_prefix}${local.image_type}-${local.license_type}"
  image_versions = {
    "R81.20" = local.is_manual || local.is_management_only ? "634-991001641-v20240807" : "631-991001709-v20241105"
    "R81.10" = local.is_manual || local.is_management_only ? "335-991001174-v20221110" : "335-991001300-v20230509"
    "R80.40" = local.is_manual || local.is_management_only ? "294-904-v20210715" : "294-904-v20210715"
  }
  image_version         = lookup(local.image_versions, local.software_version, "error")
  default_image         = "${local.image_prefix}-${local.install_code}${local.image_version}"
  image                 = coalesce(var.software_image, local.default_image)
  template_version      = "20241105"
  startup_script_file   = local.is_management_only ? "cloud-config.sh" : "startup-script.sh"
  admin_password        = local.generate_admin_password ? random_string.admin_password[0].result : var.admin_password
  sic_key               = local.generate_sic_key ? random_string.sic_key[0].result : var.sic_key
  allow_upload_download = coalesce(var.allow_upload_download, false)
  enable_monitoring     = coalesce(var.enable_monitoring, false)
  admin_shell           = coalesce(var.admin_shell, "/etc/cli.sh")
  subnet_prefix         = "projects/${local.project}/regions/${local.region}/subnetworks"
  network_names         = coalesce(var.network_names, [var.network_name])
  subnet_names          = coalesce(var.subnet_names, [var.subnet_name])
  descriptions = {
    "Cluster"   = "CloudGuard Highly Available Security Cluster"
    "AutoScale" = "None"
  }
  description          = coalesce(var.description, lookup(local.descriptions, local.install_type, "Check Point Security Gateway"))
  enable_serial_port   = coalesce(var.enable_serial_port, false)
  enable_disk_snapshot = coalesce(var.enable_disk_snapshot, local.is_management || local.is_manual ? true : false)
  snapshot_labels      = {}
  metadata = merge(
    {
      instanceSSHKey              = var.admin_ssh_key
      adminPasswordSourceMetadata = local.is_management_only ? null : local.admin_password
    },
    local.enable_serial_port ? { serial-port-enable = "true" } : {},
  )
}

# Create Compute Engine Instances
resource "google_compute_instance" "default" {
  count                     = local.create ? length(local.instances) : 0
  project                   = local.project
  name                      = local.instances[count.index].name
  description               = local.description
  zone                      = local.instances[count.index].zone
  machine_type              = local.machine_type
  labels                    = local.labels
  tags                      = local.network_tags
  can_ip_forward            = local.is_gateway ? true : false
  allow_stopping_for_update = true
  resource_policies         = []
  boot_disk {
    auto_delete = local.disk_auto_delete
    device_name = "${local.name}-boot"
    initialize_params {
      type  = local.disk_type
      size  = local.disk_size
      image = local.image
    }
  }
  # eth0 / nic0
  network_interface {
    network            = local.network_names[0]
    subnetwork_project = local.project
    subnetwork         = "${local.subnet_prefix}/${local.subnet_names[0]}"
    dynamic "access_config" {
      for_each = local.create_nic0_external_ips && (local.is_cluster ? data.google_compute_address.nic0_external_ips[count.index].status == "IN_USE" : true) ? [true] : []
      content {
        nat_ip = google_compute_address.nic0_external_ips[var.flip_members ? abs(count.index - 1 % 2) : count.index].address
      }
    }
  }
  # eth1 / nic1
  dynamic "network_interface" {
    for_each = local.is_gateway ? [true] : []
    content {
      network            = local.network_names[1]
      subnetwork_project = local.project
      subnetwork         = "${local.subnet_prefix}/${local.subnet_names[1]}"
      dynamic "access_config" {
        for_each = local.create_nic1_external_ips ? [true] : []
        content {
          nat_ip = google_compute_address.nic1_external_ips[count.index].address
        }
      }
    }
  }
  # Internal interfaces (eth2-8 / nic2-8)
  dynamic "network_interface" {
    for_each = local.is_gateway ? slice(local.network_names, 2, length(local.network_names)) : []
    content {
      network            = network_interface.value
      subnetwork_project = local.project
      subnetwork         = "${local.subnet_prefix}/${local.subnet_names[network_interface.key + 2]}"
    }
  }
  service_account {
    email  = var.service_account_email
    scopes = local.service_account_scopes
  }
  metadata = local.metadata
  metadata_startup_script = local.is_manual ? null : templatefile("${path.module}/${local.startup_script_file}", {
    // script's arguments
    generatePassword               = local.is_management_only ? "false" : "true"
    config_url                     = "https://runtimeconfig.googleapis.com/v1beta1/projects/${local.project}/configs/${local.name}-config"
    config_path                    = "projects/${local.project}/configs/${local.name}-config"
    sicKey                         = local.sic_key
    allowUploadDownload            = local.allow_upload_download
    templateName                   = local.template_name
    templateVersion                = local.template_version
    templateType                   = "terraform"
    mgmtNIC                        = local.is_management ? "Private IP (eth0)" : "Private IP (eth1)"
    hasInternet                    = "true"
    enableMonitoring               = local.enable_monitoring
    shell                          = local.admin_shell
    installationType               = local.install_type
    computed_sic_key               = local.sic_key
    managementGUIClientNetwork     = coalesce(var.allowed_gui_clients, "0.0.0.0/0") # Controls access GAIA web interface
    primary_cluster_address_name   = local.is_cluster ? local.instances[0].nic0_address_name : ""
    secondary_cluster_address_name = local.is_cluster ? local.instances[1].nic0_address_name : ""
    managementNetwork              = local.is_management ? "" : coalesce(var.sic_address, "192.0.2.132/32")
    numAdditionalNICs              = length(local.network_names) - 2
    smart_1_cloud_token            = "${local.instances[count.index].name}" == "${local.name}-member-a" ? var.smart_1_cloud_token_a : var.smart_1_cloud_token_b
    name                           = local.instances[count.index].name
    zoneConfig                     = local.instances[count.index].zone
    region                         = local.region
    MaintenanceModePassword        = ""
    /* TODO - Need to add these parameters to bash startup script
    domain_name = var.domain_name
    expert_password                = var.expert_password
    proxy_host = var.proxy_host
    proxy_port = coalesce(var.proxy_port, 8080)
    mgmt_routes = coalesce(var.mgmt_routes, "199.36.53.8/30")
    internal_routes =  coalesce(var.internal_routes, "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16")
    */
  })
}

# Unmanaged Instance Group for each gateway
resource "google_compute_instance_group" "default" {
  count       = local.create_instance_groups ? length(local.instances) : 0
  project     = local.project
  name        = google_compute_instance.default[count.index].name
  description = "Unmanaged Instance Group for ${local.instances[count.index].name}"
  network     = "projects/${local.network_project_id}/global/networks/${local.network_names[0]}"
  instances   = [google_compute_instance.default[count.index].self_link]
  zone        = local.instances[count.index].zone
}

# Perform one-time Snapshot for all disk
resource "google_compute_snapshot" "default" {
  count             = local.create && local.enable_disk_snapshot ? length(local.instances) : 0
  project           = local.project
  name              = "${local.instances[count.index].name}-snapshot"
  description       = "Disk Snapshot for ${local.instances[count.index].name}"
  source_disk       = "projects/${local.project}/zones/${local.instances[count.index].zone}/disks/${local.instances[count.index].name}"
  zone              = local.instances[count.index].zone
  labels            = local.snapshot_labels
  storage_locations = [local.region]
  depends_on        = [google_compute_instance.default]
}

# Disk Snapshot Schedule
resource "google_compute_resource_policy" "default" {
  count   = local.create && local.enable_disk_snapshot ? 1 : 0
  project = local.project
  name    = local.name
  region  = local.region
  snapshot_schedule_policy {
    retention_policy {
      max_retention_days    = 14
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    schedule {
      dynamic "daily_schedule" {
        for_each = [true]
        content {
          days_in_cycle = 1
          start_time    = "04:00"
        }
      }
      dynamic "hourly_schedule" {
        for_each = []
        content {
          hours_in_cycle = null
          start_time     = null
        }
      }
      dynamic "weekly_schedule" {
        for_each = []
        content {
          dynamic "day_of_weeks" {
            for_each = []
            content {
              day        = null
              start_time = null
            }
          }
        }
      }
    }
    dynamic "snapshot_properties" {
      for_each = [true]
      content {
        guest_flush       = false
        labels            = local.snapshot_labels
        storage_locations = [local.region]
      }
    }
  }
}

# Attach disk(s) to snapshot policy
resource "google_compute_disk_resource_policy_attachment" "default" {
  count      = local.create && local.enable_disk_snapshot ? length(local.instances) : 0
  project    = local.project
  name       = one(google_compute_resource_policy.default).name
  disk       = local.instances[count.index].name
  zone       = local.instances[count.index].zone
  depends_on = [google_compute_instance.default]
}