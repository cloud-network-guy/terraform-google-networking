resource "random_string" "random_name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = false
}

locals {
  url_prefix      = "https://www.googleapis.com/compute/v1"
  create          = coalesce(var.create, true)
  project_id      = lower(trimspace(var.project_id))
  host_project_id = lower(trimspace(coalesce(var.host_project_id, local.project_id)))
  name            = var.name != null ? lower(trimspace(replace(var.name, "_", "-"))) : one(random_string.random_name).result
  #network         = coalesce(var.network, "default")
  network       = startswith(var.network, local.url_prefix) ? var.network : startswith(var.network, "projects/") ? "${local.url_prefix}/${var.network}" : coalesce(var.network, "default")
  zone          = lower(trimspace(coalesce(var.zone, "us-central1-a")))
  region        = trimsuffix(local.zone, substr(local.zone, -2, 2))
  region_prefix = "projects/${local.project_id}/region/${local.region}"
  zone_prefix   = "projects/${local.project_id}/zones/${local.zone}"
  #index_key     = "${local.project_id}/${local.zone}/${local.name}"
  umigs = [
    {
      network     = startswith(local.network, local.url_prefix) ? local.network : "${local.url_prefix}/projects/${local.host_project_id}/global/networks/${local.network}"
      instances   = coalesce(var.instances, [])
      named_ports = coalesce(var.named_ports, [])
      index_key   = "${local.project_id}/${local.zone}/${local.name}"
    }
  ]
}

# Unmanaged Instance Groups
resource "google_compute_instance_group" "default" {
  for_each  = { for i, v in local.umigs : i => v if local.create }
  project   = local.project_id
  name      = local.name
  zone      = local.zone
  network   = each.value.network
  instances = formatlist("${local.zone_prefix}/instances/%s", each.value.instances)
  # Also do named ports within the instance group
  dynamic "named_port" {
    for_each = each.value.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}
