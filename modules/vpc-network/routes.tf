locals {
  _routes = [for i, route in coalesce(var.routes, []) :
    merge(route, {
      create      = local.create ? coalesce(route.create, true) : false
      name        = route.name != null ? lower(trimspace(route.name)) : null
      next_hop    = coalesce(route.next_hop, "default-internet-gateway")
      dest_range  = route.dest_range
      dest_ranges = coalesce(route.dest_ranges, [])
      tags        = length(coalesce(route.tags, [])) > 0 ? route.tags : null
    })
  ]
  __routes = flatten(concat(
    [for route in local._routes :
      # Routes that have more than one destination range
      [for i, dest_range in route.dest_ranges :
        merge(route, {
          name       = "${route.name}-${replace(replace(dest_range, ".", "-"), "/", "-")}-${route.priority}"
          dest_range = dest_range
        })
      ]
    ],
    # Routes with a single destination range
    [for route in local._routes :
      merge(route, {
        name = replace(coalesce(route.name, replace("${local.network_name}-${route.dest_range}", ".", "-")), "/", "-")
      }) if route.dest_range != null
    ]
  ))
  ___routes = [for route in local.__routes :
    merge(route, {
      next_hop_type = can(regex("^[1-2]", route.next_hop)) ? "ip" : (endswith(route.next_hop, "gateway") ? "gateway" : "instance")
    })
  ]
  routes = [for route in local.___routes :
    merge(route, {
      next_hop_gateway       = route.next_hop_type == "gateway" ? "${local.api_prefix}/projects/${local.project}/global/gateways/${route.next_hop}" : null
      next_hop_ip            = route.next_hop_type == "ip" ? route.next_hop : null
      next_hop_instance      = route.next_hop_type == "instance" ? route.next_hop : null
      next_hop_instance_zone = route.next_hop_type == "instance" ? route.next_hop_zone : null
      index_key              = "${local.project}/${route.name}"
    })
  ]
}
resource "google_compute_route" "default" {
  for_each               = { for i, v in local.routes : v.name => v if v.create }
  project                = local.project
  network                = local.network_self_link
  name                   = each.value.name
  description            = each.value.description
  dest_range             = each.value.dest_range
  priority               = each.value.priority
  tags                   = each.value.tags
  next_hop_gateway       = each.value.next_hop_gateway
  next_hop_ip            = each.value.next_hop_ip
  next_hop_instance      = each.value.next_hop_instance
  next_hop_instance_zone = each.value.next_hop_instance_zone
  timeouts {
    create = null
    delete = null
  }
  # https://github.com/hashicorp/terraform-provider-google/issues/3034
  depends_on = [google_compute_network_peering.default]
}
