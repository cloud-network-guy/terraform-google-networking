resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  create      = coalesce(var.create, true)
  project     = lower(trimspace(var.project_id))
  name        = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description = var.description
  logging     = coalesce(var.logging, false)
}

# Get Current IP Ranges from Google via Data Source
data "google_netblock_ip_ranges" "default" {
  for_each   = local.create ? toset(local.range_types) : {}
  range_type = each.value
}

resource "google_compute_firewall" "default" {
  count                   = local.create ? 1 : 0
  project                 = local.project
  network                 = local.network_self_link
  name                    = local.name
  description             = local.description
  priority                = local.priority
  direction               = local.direction
  disabled                = local.disabled
  source_ranges           = local.source_ranges
  source_tags             = local.source_tags
  source_service_accounts = local.source_service_accounts
  destination_ranges      = local.destination_ranges
  dynamic "allow" {
    for_each = local.action == "ALLOW" ? local.traffic : []
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
  dynamic "deny" {
    for_each = local.action == "DENY" ? local.traffic : []
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
  dynamic "log_config" {
    for_each = local.logging ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
  target_tags             = local.target_tags
  target_service_accounts = local.target_service_accounts
  timeouts {
    create = null
    delete = null
    update = null
  }
}

