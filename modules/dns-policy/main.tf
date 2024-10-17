
locals {
  create                    = coalesce(var.create, true)
  project                   = lower(trimspace(var.project_id))
  name                      = lower(trimspace(var.name))
  description               = var.description
  logging                   = coalesce(var.logging, false)
  enable_inbound_forwarding = coalesce(var.enable_inbound_forwarding, false)
  target_name_servers = [for ns in var.target_name_servers :
    {
      ipv4_address    = ns.ipv4_address
      forwarding_path = trimspace(lower(lookup(ns, "forwarding_path", "default")))
    }
  ]
  networks = [for n in var.networks :
    strcontains(n, "projects/") ? n : "projects/${local.project}/global/networks/${n}"
  ]
}

resource "null_resource" "default" {
  count = local.create ? 1 : 0
}
resource "google_dns_policy" "default" {
  count                     = local.create ? 1 : 0
  project                   = local.project
  name                      = local.name
  description               = local.description
  enable_logging            = local.logging
  enable_inbound_forwarding = local.enable_inbound_forwarding
  dynamic "alternative_name_server_config" {
    for_each = length(local.target_name_servers) > 0 ? [true] : []
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
  dynamic "networks" {
    for_each = local.networks
    content {
      network_url = networks.value
    }
  }
  depends_on = [null_resource.default]
}
