
# If no name provided, generate a random one
resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = false
}

locals {
  create          = coalesce(var.create, true)
  project_id      = lower(trimspace(var.project_id))
  host_project_id = lower(trimspace(coalesce(var.host_project_id, local.project_id)))
  name            = var.name != null ? lower(trimspace(var.name)) : one(random_string.name).result
  description     = trimspace(coalesce(var.description, "Managed by Terraform"))
  is_zonal        = var.zone != null ? true : false
  is_regional     = var.region != null && var.region != "global" && !local.is_zonal ? true : false
  is_global       = !local.is_regional && !local.is_zonal ? true : false
  region          = local.is_regional ? lower(trimspace(var.region)) : local.is_zonal ? substr(local.zone, 0, length(local.zone) - 2) : "global"
  zone            = local.is_zonal ? lower(trimspace(var.zone)) : null
  is_psc          = var.psc_target != null ? true : false
  default_port    = try(coalesce(var.default_port, var.port), null)
  _negs = [
    {
      project_id = local.project_id
      region     = local.region
      name       = local.name
      #description = local.description
      endpoints = [for e in coalesce(var.endpoints, []) :
        merge(e, {
          project_id = local.project_id
          ip_address = lookup(e, "ip_address", var.ip_address)
          fqdn       = lookup(e, "fqdn", var.fqdn)
          port       = lookup(e, "port", local.default_port)
        })
      ]
    }
  ]
  negs = [for i, v in local._negs :
    merge(v, {
      network_endpoint_type = coalesce(
        var.fqdn != null ? "INTERNET_FQDN_PORT" : null,
        var.ip_address != null ? "INTERNET_IP_PORT" : null,
        length([for e in v.endpoints : e if e.fqdn != null]) > 0 ? "INTERNET_FQDN_PORT" : null,
        length([for e in v.endpoints : e if e.ip_address != null]) > 0 ? "INTERNET_IP_PORT" : null,
        "INTERNET_IP_PORT",
        "UNKNOWN"
      )
    }) if local.create == true
  ]
}

# Global Network Endpoint Groups
locals {
  gnegs = [for i, v in local.negs :
    merge(v, {
      default_port = local.default_port
      index_key    = "${local.project_id}/${local.name}"
    }) if local.is_global && !local.is_psc
  ]
}
resource "null_resource" "gnegs" {
  for_each = { for i, v in local.gnegs : v.index_key => true }
}
resource "google_compute_global_network_endpoint_group" "default" {
  for_each              = { for i, v in local.gnegs : v.index_key => v }
  project               = each.value.project_id
  name                  = each.value.name
  network_endpoint_type = each.value.network_endpoint_type
  default_port          = each.value.default_port
  depends_on            = [null_resource.gnegs]
}

# Global Network Endpoints
locals {
  _gneg_endpoints = flatten([for i, v in local.gnegs :
    [for e in v.endpoints :
      merge(e, {
        port          = coalesce(e.port, v.default_port, 443) # This is going via Internet, so let's assume HTTPS
        neg_name      = v.name
        neg_index_key = v.index_key
      })
    ]
  ])
  gneg_endpoints = [for i, v in local._gneg_endpoints :
    merge(v, {
      index_key = "${local.project_id}/${v.neg_name}/${try(coalesce(v.ip_address), "")}/${try(coalesce(v.fqdn), "")}/${v.port}"
    })
  ]
}
resource "google_compute_global_network_endpoint" "default" {
  for_each                      = { for i, v in local.gneg_endpoints : v.index_key => v }
  project                       = each.value.project_id
  global_network_endpoint_group = google_compute_global_network_endpoint_group.default[each.value.neg_index_key].id
  fqdn                          = each.value.fqdn
  ip_address                    = each.value.ip_address
  port                          = each.value.port
}

# Regional Network Endpoint Groups
locals {
  _rnegs = [for i, v in local.negs :
    merge(v, {
      network_endpoint_type = local.is_psc ? "PRIVATE_SERVICE_CONNECT" : "SERVERLESS"
      network               = local.is_psc ? null : coalesce(var.network, "default")
      subnetwork            = local.is_psc ? coalesce(var.subnet, "default") : null
      psc_target_service    = local.is_psc ? lower(trimspace(var.psc_target)) : null
      cloud_run_service     = var.cloud_run_service != null ? lower(trimspace(var.cloud_run_service)) : null
    }) if local.is_regional
  ]
  rnegs = [for i, v in local._rnegs :
    merge(v, {
      index_key = "${local.project_id}/${local.region}/${local.name}"
    }) if local.create
  ]
}
resource "null_resource" "rnegs" {
  for_each = { for i, v in local.rnegs : v.index_key => true }
}
resource "google_compute_region_network_endpoint_group" "default" {
  for_each              = { for i, v in local.rnegs : v.index_key => v }
  project               = each.value.project_id
  name                  = each.value.name
  network_endpoint_type = each.value.network_endpoint_type
  region                = each.value.region
  psc_target_service    = each.value.psc_target_service
  network               = each.value.network
  subnetwork            = each.value.subnetwork
  dynamic "cloud_run" {
    for_each = each.value.cloud_run_service != null ? [true] : []
    content {
      service = each.value.cloud_run_service
    }
  }
  depends_on = [null_resource.rnegs]
}

# Regional Network Endpoints
locals {
  rneg_endpoints = flatten([for i, v in local.rnegs :
    [for e in v.endpoints :
      merge(e, {
        group_index_key = v.index_key
      })
    ]
  ])
}
resource "google_compute_region_network_endpoint" "default" {
  for_each                      = { for i, v in local.rneg_endpoints : v.index_key => v }
  project                       = each.value.project_id
  region_network_endpoint_group = google_compute_region_network_endpoint_group.default[each.value.group_index_key].id
  fqdn                          = each.value.fqdn
  ip_address                    = each.value.ip_address
  port                          = each.value.port
  region                        = each.value.region
  depends_on                    = [null_resource.rnegs]
}

# Zonal Network Endpoint Groups
locals {
  _znegs = [for i, v in local.negs :
    merge(v, {
      network_endpoint_type = local.default_port == null ? "GCE_VM_IP" : "GCE_VM_IP_PORT"
      zone                  = local.zone
      network               = coalesce(var.network, "default")
      subnetwork            = coalesce(var.subnet, "default")
      default_port          = local.default_port
      endpoints = [for e in v.endpoints :
        merge(e, {
          port       = lookup(e, "port", local.default_port)
        })
      ]
    }) if local.is_zonal
  ]
  znegs = [for i, v in local._znegs :
    merge(v, {
      network    = startswith(v.network, "projects/") ? v.network : "projects/${local.host_project_id}/global/networks/${v.network}"
      subnetwork = startswith(v.subnetwork, "projects/") ? v.subnetwork : "projects/${local.host_project_id}/regions/${local.region}/subnetworks/${v.subnetwork}"
      index_key  = "${local.project_id}/${local.zone}/${local.name}"
    }) if local.create == true
  ]
}
resource "null_resource" "znegs" {
  for_each = { for i, v in local.znegs : v.index_key => true }
}
resource "google_compute_network_endpoint_group" "default" {
  for_each              = { for i, v in local.znegs : v.index_key => v }
  project               = each.value.project_id
  name                  = each.value.name
  network_endpoint_type = each.value.network_endpoint_type
  zone                  = each.value.zone
  network               = each.value.network
  subnetwork            = each.value.subnetwork
  default_port          = each.value.default_port
  depends_on            = [null_resource.znegs]
}

# Zonal Network Endpoints
locals {
  _zneg_endpoints = flatten([for i, v in local.znegs :
    [for e in v.endpoints :
      merge(e, {
        zone          = v.zone
        neg_name      = v.name
        neg_index_key = v.index_key
        port          = coalesce(e.port, v.default_port, 80)
      })
    ]
  ])
  zneg_endpoints = [for i, v in local._zneg_endpoints :
    merge(v, {
      index_key = "${local.project_id}/${v.zone}/${v.neg_name}/${try(coalesce(v.instance), "")}/${try(coalesce(v.ip_address), "")}/${v.port}"
    })
  ]
}
resource "google_compute_network_endpoint" "default" {
  for_each               = { for i, v in local.zneg_endpoints : v.index_key => v }
  project                = each.value.project_id
  network_endpoint_group = google_compute_network_endpoint_group.default[each.value.neg_index_key].id
  zone                   = each.value.zone
  instance               = each.value.instance
  ip_address             = each.value.ip_address
  port                   = each.value.port
  depends_on             = [null_resource.znegs]
}
