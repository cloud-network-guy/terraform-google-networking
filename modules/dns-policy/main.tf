resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix                = "https://www.googleapis.com/compute/v1"
  create                    = coalesce(var.create, true)
  project                   = lower(trimspace(coalesce(var.project, var.project_id)))
  name                      = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description               = var.description
  logging                   = coalesce(var.logging, false)
  enable_inbound_forwarding = coalesce(var.enable_inbound_forwarding, false)
  target_name_servers = [for target_name_server in coalesce(var.target_name_servers, []) :
    {
      ipv4_address    = trimspace(target_name_server.ipv4_address)
      forwarding_path = trimspace(lower(lookup(target_name_server, "forwarding_path", "default")))
    }
  ]
  networks = [for network in coalesce(var.networks, compact([var.network])) : trimspace(coalesce(
    startswith(network, "${local.api_prefix}/projects/") ? network : null,
    startswith(network, "projects/") ? "${local.api_prefix}/${network}" : null,
    "${local.api_prefix}/projects/${local.project}/global/networks/${network}"
    ))
  ]
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
}
