locals {
  _subnets = [for i, v in coalesce(var.subnets, []) :
    merge(v, {
      create               = local.create ? coalesce(v.create, true) : false
      name                 = lower(trimspace(coalesce(v.name, "subnet-${i}")))
      purpose              = upper(trimspace(coalesce(v.purpose, "PRIVATE")))
      region               = coalesce(v.region, var.default_region)
      private_access       = coalesce(v.private_access, false)
      aggregation_interval = upper(coalesce(v.log_aggregation_interval, "INTERVAL_5_SEC"))
      flow_sampling        = coalesce(v.log_sampling_rate, 0.5)
      log_metadata         = "INCLUDE_ALL_METADATA"
      flow_logs            = coalesce(v.flow_logs, false)
      stack_type           = upper(coalesce(v.stack_type, "IPV4_ONLY"))
      attached_projects    = coalesce(v.attached_projects, [])
      shared_accounts      = coalesce(v.shared_accounts, [])
      viewer_accounts      = coalesce(v.viewer_accounts, [])
      secondary_ranges = [for i, r in coalesce(v.secondary_ranges, []) :
        {
          name  = trimspace(coalesce(r.name, "secondary-range-${i}"))
          range = r.range
        }
      ]
      psc_endpoints = coalesce(v.psc_endpoints, [])
    })
  ]
  subnets = [for i, v in local._subnets :
    merge(v, {
      is_ipv6_enabled      = v.stack_type == "IPV4_ONLY" ? false : true
      is_private           = v.purpose == "PRIVATE" ? true : false
      is_proxy_only        = v.purpose == "INTERNAL_HTTPS_LOAD_BALANCER" || endswith(v.purpose, "MANAGED_PROXY") ? true : false
      has_secondary_ranges = length(v.secondary_ranges) > 0 ? true : false
      attached_projects    = concat(v.attached_projects, local.attached_projects)
      shared_accounts      = concat(v.shared_accounts, local.shared_accounts)
      viewer_accounts      = concat(v.viewer_accounts, local.viewer_accounts)
      index_key            = "${local.project}/${v.region}/${v.name}"
    })
  ]
}

# Work-around for scenarios where a subnet is destroyed/re-created due to name change
resource "null_resource" "subnets" {
  for_each = { for i, v in local.subnets : "${v.region}/${v.name}" => true if v.create }
}

resource "google_compute_subnetwork" "default" {
  for_each                   = { for i, v in local.subnets : "${v.region}/${v.name}" => v if v.create }
  project                    = local.project
  network                    = local.network_self_link
  name                       = each.value.name
  description                = each.value.description
  region                     = each.value.region
  stack_type                 = each.value.is_private ? each.value.stack_type : null
  ipv6_access_type           = null # each.value.is_proxy_only ? "INTERNAL" : null
  ip_cidr_range              = each.value.ip_range
  purpose                    = each.value.purpose
  role                       = each.value.is_proxy_only ? upper(coalesce(each.value.role, "active")) : null
  private_ip_google_access   = each.value.is_private ? each.value.private_access : false
  private_ipv6_google_access = each.value.is_private ? "DISABLE_GOOGLE_ACCESS" : null   # TODO
  # https://github.com/hashicorp/terraform-plugin-sdk/issues/161
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.name
      ip_cidr_range = secondary_ip_range.value.range
    }
  }
  dynamic "log_config" {
    for_each = each.value.flow_logs && each.value.is_private ? [true] : []
    content {
      aggregation_interval = each.value.aggregation_interval
      flow_sampling        = each.value.flow_sampling
      metadata             = each.value.log_metadata
      metadata_fields      = []
    }
  }
  depends_on = [null_resource.subnets]
}
