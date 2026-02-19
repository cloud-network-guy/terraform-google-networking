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
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  network = var.network != null ? trimspace(coalesce(
    startswith(var.network, local.api_prefix) ? var.network : null,
    startswith(var.network, "projects/") ? "${local.api_prefix}/${var.network}" : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )) : null
  name        = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description = var.description != null ? trimspace(var.description) : null
  is_regional = var.region != null ? true : false
  region      = local.is_regional ? var.region : "global"
  target_service = var.target_service != null ? trimspace(coalesce(
    startswith(var.target_service, local.api_prefix) ? var.target_service : null,
    startswith(var.target_service, "projects/") ? "${local.api_prefix}/${var.target_service}" : null,
    "projects/${local.project}/regions/${local.region}/forwardingRules/${var.target_service}",
  )) : null
  reconcile_connections    = coalesce(var.reconcile_connections, true)
  enable_proxy_protocol    = coalesce(var.enable_proxy_protocol, false)
  auto_accept_all_projects = coalesce(var.auto_accept_all_projects, false)
  consumer_accept_list = [for p in coalesce(var.consumer_accept_list, []) :
    {
      project_id_or_num = p.project
      connection_limit  = coalesce(p.connection_limit, 10)
    }
  ]
  consumer_reject_list = coalesce(var.consumer_reject_list, [])
  domain_names         = coalesce(var.domain_names, [])
  host_project_id      = coalesce(var.host_project, local.host_project)
  nat_subnet           = coalesce(var.nat_subnet, "error")
  nat_subnets = [for nat_subnet in coalescelist(var.nat_subnets, compact([local.nat_subnet])) :
    coalesce(
      startswith(nat_subnet, local.api_prefix) ? nat_subnet : null,
      startswith(nat_subnet, "projects/", ) ? "${local.api_prefix}/${nat_subnet}" : null,
      "${local.api_prefix}/projects/${local.host_project}/regions/${local.region}/subnetworks/${nat_subnet}",
    )
  ]
}

resource "google_compute_service_attachment" "default" {
  count                 = local.create ? 1 : 0
  project               = local.project
  name                  = local.name
  region                = local.region
  description           = local.description
  enable_proxy_protocol = local.enable_proxy_protocol
  nat_subnets           = local.nat_subnets
  target_service        = local.target_service
  connection_preference = local.auto_accept_all_projects ? "ACCEPT_AUTOMATIC" : "ACCEPT_MANUAL"
  dynamic "consumer_accept_lists" {
    for_each = local.consumer_accept_list
    content {
      project_id_or_num = consumer_accept_lists.value.project_id_or_num
      connection_limit  = consumer_accept_lists.value.connection_limit
    }
  }
  consumer_reject_lists = []
  domain_names          = local.domain_names
  reconcile_connections = local.reconcile_connections
}
