
locals {
  create      = coalesce(var.create, true)
  project     = lower(trimspace(var.project_id))
  name        = lower(trimspace(var.name))
  description = var.description
  dns_name    = lower(trimspace(endswith(var.dns_name, ".") ? var.dns_name : "${var.dns_name}."))
  logging     = coalesce(var.logging, false)
  visibility  = lower(coalesce(var.visibility, "public"))
  is_private  = lower(trimspace(local.visibility)) == "private" ? true : false
  target_name_servers = [for ns in var.target_name_servers :
    {
      ipv4_address    = ns.ipv4_address
      forwarding_path = trimspace(lower(lookup(ns, "forwarding_path", "default")))
    }
  ]
  networks = [for n in var.networks :
    strcontains(n, "projects/") ? n : "projects/${local.project}/global/networks/${n}"
  ]
  force_destroy = coalesce(var.force_destroy, false)
  peer_project  = coalesce(var.peer_project_id, var.peer_project, local.project)
  _peer_network = try(coalesce(var.peer_network_id, var.peer_network), null)
  peer_network  = local._peer_network != null ? strcontains(local._peer_network, "projects/") ? local._peer_network : "projects/${local.peer_project}/global/networks/${local._peer_network}" : null
}

# The DNS Zone
resource "null_resource" "default" {
  count = local.create ? 1 : 0
}
resource "google_dns_managed_zone" "default" {
  count         = local.create ? 1 : 0
  project       = local.project
  name          = local.name
  description   = local.description
  dns_name      = local.dns_name
  visibility    = local.visibility
  force_destroy = local.force_destroy
  dynamic "private_visibility_config" {
    for_each = local.is_private && length(local.networks) > 0 ? [true] : []
    content {
      dynamic "networks" {
        for_each = local.networks
        content {
          network_url = networks.value
        }
      }
    }
  }
  dynamic "forwarding_config" {
    for_each = local.is_private && length(local.target_name_servers) > 0 ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = local.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = target_name_servers.value.forwarding_path
        }
      }
    }
  }
  dynamic "peering_config" {
    for_each = local.peer_network != null ? [true] : []
    content {
      target_network {
        network_url = local.peer_network
      }
    }
  }
  dynamic "cloud_logging_config" {
    for_each = local.logging ? [true] : []
    content {
      enable_logging = true
    }
  }
  depends_on = [null_resource.default]
}

locals {
  _dns_records = [for r in var.records :
    {
      create  = coalesce(lookup(r, "create", null), true)
      name    = trimspace(endswith(r.name, local.dns_name) ? r.name : "${r.name}.${local.dns_name}")
      type    = upper(trimspace(coalesce(lookup(r, "type", null), "A")))
      ttl     = coalesce(lookup(r, "ttl", null), 300)
      rrdatas = [for _ in coalesce(lookup(r, "rrdatas", null), []) : trimspace(_)]
    }
  ]
  dns_records = [for r in local._dns_records :
    merge(r, {
      index_key = "${one(google_dns_managed_zone.default).name}/${r.name}/${r.type}"
    }) if r.create == true
  ]
}

# DNS Records
resource "google_dns_record_set" "default" {
  for_each     = { for k, v in local.dns_records : v.index_key => v }
  project      = local.project
  managed_zone = local.create ? one(google_dns_managed_zone.default).name : null
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
  depends_on   = [google_dns_managed_zone.default]
}
