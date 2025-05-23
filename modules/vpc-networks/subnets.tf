locals {
  _subnets = flatten([for vpc_network in local.vpc_networks :
    [for i, v in coalesce(vpc_network.subnets, []) :
      merge(v, {
        create               = coalesce(v.create, true)
        project_id           = coalesce(v.project_id, vpc_network.project_id, var.project_id)
        name                 = lower(trimspace(coalesce(v.name, "subnet-${i}")))
        network_name         = google_compute_network.default[vpc_network.index_key].name
        purpose              = upper(trimspace(coalesce(v.purpose, "PRIVATE")))
        region               = coalesce(v.region, var.region)
        private_access       = coalesce(v.private_access, var.defaults.subnet_private_access, false)
        aggregation_interval = upper(coalesce(v.log_aggregation_interval, var.defaults.subnet_log_aggregation_interval, "INTERVAL_5_SEC"))
        flow_sampling        = coalesce(v.log_sampling_rate, var.defaults.subnet_log_sampling_rate, 0.5)
        log_metadata         = "INCLUDE_ALL_METADATA"
        flow_logs            = coalesce(v.flow_logs, var.defaults.subnet_flow_logs, false)
        stack_type           = upper(coalesce(v.stack_type, var.defaults.subnet_stack_type, "IPV4_ONLY"))
        attached_projects    = concat(coalesce(v.attached_projects, []), coalesce(vpc_network.attached_projects, []))
        shared_accounts      = concat(coalesce(v.shared_accounts, []), coalesce(vpc_network.shared_accounts, []))
        viewer_accounts      = concat(coalesce(v.viewer_accounts, []), coalesce(vpc_network.viewer_accounts, []))
        secondary_ranges = [for i, r in coalesce(v.secondary_ranges, []) :
          {
            name  = trimspace(coalesce(r.name, "secondary-range-${i}"))
            range = r.range
          }
        ]
        psc_endpoints = coalesce(v.psc_endpoints, [])
      })
    ]
  ])
  subnets = [for i, v in local._subnets :
    merge(v, {
      is_private           = v.purpose == "PRIVATE" ? true : false
      is_proxy_only        = v.purpose == "INTERNAL_HTTPS_LOAD_BALANCER" || endswith(v.purpose, "MANAGED_PROXY") ? true : false
      has_secondary_ranges = length(v.secondary_ranges) > 0 ? true : false
      network              = "${local.url_prefix}/${v.project_id}/global/networks/${v.network_name}"
      index_key            = "${v.project_id}/${v.region}/${v.name}"
    }) if v.create == true
  ]
}

# Work-around for scenarios where a subnet is destroyed/re-created due to name change
resource "null_resource" "subnets" {
  for_each = { for i, v in local.subnets : v.index_key => true }
}

resource "google_compute_subnetwork" "default" {
  for_each                 = { for i, v in local.subnets : v.index_key => v }
  project                  = var.project_id
  name                     = each.value.name
  description              = each.value.description
  network                  = each.value.network
  region                   = each.value.region
  stack_type               = each.value.is_private ? each.value.stack_type : null
  ipv6_access_type         = null # each.value.is_proxy_only ? "INTERNAL" : null
  ip_cidr_range            = each.value.ip_range
  purpose                  = each.value.purpose
  role                     = each.value.is_proxy_only ? upper(coalesce(each.value.role, "active")) : null
  private_ip_google_access = each.value.is_private ? each.value.private_access : null
  dynamic "log_config" {
    for_each = each.value.flow_logs && each.value.is_private ? [true] : []
    content {
      aggregation_interval = each.value.aggregation_interval
      flow_sampling        = each.value.flow_sampling
      metadata             = each.value.log_metadata
      metadata_fields      = []
    }
  }
  /* https://github.com/hashicorp/terraform-plugin-sdk/issues/161
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.name
      ip_cidr_range = secondary_ip_range.value.range
    }
  }
  */
  secondary_ip_range = [for i, v in each.value.secondary_ranges :
    {
      range_name    = v.name
      ip_cidr_range = v.range
    }
  ]
  depends_on = [google_compute_network.default, null_resource.subnets]
}
