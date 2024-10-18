
locals {
  url_prefix             = "https://www.googleapis.com/compute/v1"
  region                 = "us-central1" # only if neither region nor zone were specified
  machine_type           = "e2-micro"    # because it's the cheapest
  os_project             = "debian-cloud"
  os                     = "debian-11" # GCP default as of 2023
  service_account_scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring"]
  metadata = {
    enable-osconfig         = "true"
    enable-guest-attributes = "true"
  }
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


locals {
  _instance_templates = [for i, v in var.instance_templates :
    merge(v, {
      create                 = coalesce(v.create, true)
      project_id             = coalesce(v.project_id, v.project_id)
      host_project_id        = coalesce(v.host_project_id, var.host_project_id, v.project_id, var.project_id)
      name_prefix            = lower(trimspace(coalesce(v.name_prefix, "template-${i + 1}")))
      network                = coalesce(v.network, "default")
      subnet                 = coalesce(v.subnet, "default")
      can_ip_forward         = coalesce(v.can_ip_forward, false)
      disk_boot              = coalesce(v.disk_boot, true)
      disk_auto_delete       = coalesce(v.disk_auto_delete, true)
      disk_type              = coalesce(v.disk_type, "pd-standard")
      disk_size_gb           = coalesce(v.disk_size, 20)
      os_project             = coalesce(v.os_project, local.os_project)
      os                     = coalesce(v.os, local.os)
      machine_type           = coalesce(v.machine_type, local.machine_type)
      labels                 = { for k, v in coalesce(v.labels, {}) : k => lower(replace(v, " ", "_")) }
      service_account_scopes = coalescelist(v.service_account_scopes, ["cloud-platform"])
      metadata               = merge(local.metadata, v.metadata, v.ssh_key != null ? { instanceSSHKey = v.ssh_key } : {})
    })
  ]
  instance_templates = [for i, v in local._instance_templates :
    merge(v, {
      tags               = v.network_tags
      network            = "projects/${v.host_project_id}/global/networks/${v.network}"
      subnetwork_project = v.host_project_id
      subnetwork         = startswith("projects/", v.subnet) ? v.subnet : "projects/${v.host_project_id}/regions/${v.region}/subnetworks/${v.subnet}"
      source_image       = coalesce(v.image, "${v.os_project}/${v.os}")
      index_key          = "${v.project_id}/${v.name_prefix}"
    }) if v.create
  ]
}

resource "google_compute_instance_template" "default" {
  for_each                = { for i, v in local.instance_templates : v.index_key => v }
  project                 = each.value.project_id
  name_prefix             = each.value.name_prefix
  description             = each.value.description
  machine_type            = each.value.machine_type
  labels                  = each.value.labels
  tags                    = each.value.tags
  metadata                = each.value.metadata
  metadata_startup_script = each.value.startup_script
  can_ip_forward          = each.value.can_ip_forward
  disk {
    disk_type    = each.value.disk_type
    disk_size_gb = each.value.disk_size
    source_image = each.value.source_image
    auto_delete  = each.value.disk_auto_delete
    boot         = each.value.disk_boot
  }
  network_interface {
    network            = each.value.network
    subnetwork_project = each.value.subnetwork_project
    subnetwork         = each.value.subnetwork
    queue_count        = 0
  }
  service_account {
    email  = each.value.service_account_email
    scopes = each.value.service_account_scopes
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}



locals {
  autoscalers = [for i, v in local.migs :
    {
      project_id            = v.project_id
      name                  = v.name_prefix
      region                = v.region
      target                = try(google_compute_region_instance_group_manager.default[v.index_key].self_link, null)
      mode                  = v.autoscaling_mode
      min_replicas          = v.autoscaling_mode != "OFF" ? coalesce(v.min_replicas, 1) : 0
      max_replicas          = v.autoscaling_mode != "OFF" ? coalesce(v.max_replicas, 10) : 0
      cooldown_period       = coalesce(v.cooldown_period, 60)
      cpu_target            = coalesce(v.cpu_target, 0.60)
      cpu_predictive_method = coalesce(v.cpu_predictive_method, "NONE")
      is_regional           = v.is_regional
      index_key             = v.index_key
    } if v.autoscaling_mode != "OFF"
  ]
}
resource "google_compute_region_autoscaler" "default" {
  for_each = { for i, v in local.autoscalers : v.index_key => v if v.is_regional }
  name     = each.value.name
  project  = each.value.project_id
  region   = each.value.region
  target   = each.value.target
  autoscaling_policy {
    max_replicas    = each.value.max_replicas
    min_replicas    = each.value.min_replicas
    cooldown_period = each.value.cooldown_period
    mode            = each.value.mode
    cpu_utilization {
      target            = each.value.cpu_target
      predictive_method = each.value.cpu_predictive_method
    }
  }
}

locals {
  _migs = [for i, v in var.migs :
    merge(v, {
      create                                = coalesce(v.create, true)
      project_id                            = coalesce(v.project_id, var.project_id)
      base_instance_name                    = coalesce(v.base_instance_name, v.name_prefix)
      region                                = coalesce(v.region, var.region)
      distribution_target_shape             = upper(coalesce(v.distribution_policy_target_shape, "EVEN"))
      update_type                           = upper(coalesce(v.update_type, "OPPORTUNISTIC"))
      update_instance_redistribution_type   = upper(coalesce(v.update_instance_redistribution_type, "PROACTIVE"))
      update_minimal_action                 = upper(coalesce(v.update_minimal_action, "RESTART"))
      update_most_disruptive_allowed_action = upper(coalesce(v.update_most_disruptive_action, "REPLACE"))
      replacement_method                    = upper(coalesce(v.update_replacement_method, "SUBSTITUTE"))
      initial_delay_sec                     = coalesce(v.auto_healing_initial_delay, 300)
    })
  ]
}

locals {
  __migs = [for i, v in local._migs :
    merge(v, {
      name             = coalesce(v.name, v.name_prefix, "mig-${i}")
      hc_prefix        = "projects/${v.project_id}/${v.region != null ? "regions/${v.region}" : "global"}"
      zones            = try(data.google_compute_zones.available[v.region].names, [for z in ["b", "c"] : "${v.region}-${z}"])
      autoscaling_mode = upper(coalesce(v.autoscaling_mode, v.min_replicas != null || v.max_replicas != null ? "ON" : "OFF"))
      is_regional      = v.region != null ? true : false
    })
  ]
  migs = [for i, v in local.__migs :
    merge(v, {
      version_name = "${v.name}-0"
      target_size  = v.autoscaling_mode == "OFF" ? coalesce(v.target_size, 2) : null
      healthchecks = [for hc in v.healthchecks :
        {
          id = coalesce(hc.id, hc.name != null ? "${v.hc_prefix}/healthChecks/${hc.name}" : null)
        }
      ]
      update_max_unavailable_fixed = length(v.zones)
      update_max_surge_fixed       = length(v.zones)
      index_key                    = "${v.project_id}/${v.region}/${v.name}"
      instance_template_key        = "${v.project_id}/${v.name_prefix}"
    }) if v.create == true
  ]
}


# Regional Managed Instance Groups
resource "google_compute_region_instance_group_manager" "default" {
  for_each                         = { for i, v in local.migs : v.index_key => v if v.is_regional }
  project                          = each.value.project_id
  base_instance_name               = each.value.base_instance_name
  name                             = each.value.name
  region                           = each.value.region
  distribution_policy_target_shape = each.value.distribution_policy_target_shape
  distribution_policy_zones        = each.value.zones
  target_size                      = each.value.target_size
  wait_for_instances               = false
  version {
    name              = each.value.version_name
    instance_template = try(google_compute_instance_template.default[each.value.instance_template_key].id, null)
  }
  dynamic "auto_healing_policies" {
    for_each = each.value.healthchecks
    content {
      health_check      = auto_healing_policies.value.id
      initial_delay_sec = each.value.initial_delay_sec
    }
  }
  update_policy {
    type                           = each.value.update_type
    instance_redistribution_type   = each.value.update_instance_redistribution_type
    minimal_action                 = each.value.update_minimal_action
    most_disruptive_allowed_action = each.value.update_most_disruptive_action
    replacement_method             = each.value.update_replacement_method
    max_unavailable_fixed          = each.value.update_max_unavailable_fixed
    max_surge_fixed                = each.value.update_max_surge_fixed
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [distribution_policy_zones]
  }
  timeouts {
    create = "5m"
    update = "5m"
    delete = "15m"
  }
  depends_on = [google_compute_instance_template.default]
}

