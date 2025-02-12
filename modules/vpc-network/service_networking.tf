# Network IP Ranges
locals {
  _ip_ranges = [for i, range in coalesce(var.ip_ranges, []) :
    {
      create        = local.create ? coalesce(range.create, true) : false
      name          = lower(trimspace(coalesce(range.name, "ip-range-${local.network_name}-${i}")))
      description   = range.description
      ip_version    = null
      address       = element(split("/", range.ip_range), 0)
      prefix_length = element(split("/", range.ip_range), 1)
      address_type  = "INTERNAL"
      purpose       = upper(trimspace(coalesce(range.purpose, "VPC_PEERING")))
    }
  ]
  ip_ranges = [for i, range in local._ip_ranges :
    merge(range, {
      index_key = "${local.project}/${range.name}"
    })
  ]
}
resource "google_compute_global_address" "psa_ranges" {
  for_each      = { for i, v in local.ip_ranges : v.name => v if v.create }
  project       = local.project
  name          = each.value.name
  description   = each.value.description
  ip_version    = each.value.ip_version
  address       = each.value.address
  prefix_length = each.value.prefix_length
  address_type  = each.value.address_type
  purpose       = each.value.purpose
  network       = local.network_self_link
}

# Private Service Access Connection
locals {
  _service_connections = [for i, connection in coalesce(var.service_connections, []) :
    merge(connection, {
      create               = local.create ? coalesce(connection.create, true) : false
      name                 = lower(trimspace(coalesce(connection.name, "service-networking-${i}")))
      service              = lower(trimspace(coalesce(connection.service, "servicenetworking.googleapis.com")))
      import_custom_routes = coalesce(connection.import_custom_routes, false)
      export_custom_routes = coalesce(connection.export_custom_routes, false)
      ip_ranges            = [for ip_range in coalesce(connection.ip_ranges, []) : lower(trimspace(ip_range))]
    })
  ]
  service_connections = [for connection in local._service_connections :
    merge(connection, {
      reserved_peering_ranges = [for ip_range in connection.ip_ranges :
        google_compute_global_address.psa_ranges[ip_range].name if connection.create == true
      ]
      peering_routes_config = connection.import_custom_routes || connection.export_custom_routes ? true : false
      index_key             = "${local.project}/${local.network_name}:${connection.service}"
    })
  ]
}
resource "google_service_networking_connection" "default" {
  for_each                = { for i, v in local.service_connections : v.service => v if v.create == true }
  network                 = local.network
  service                 = each.value.service
  reserved_peering_ranges = each.value.ip_ranges
}

# Extra Step to handle route import/export on peering connections
resource "google_compute_network_peering_routes_config" "default" {
  for_each             = { for i, v in local.service_connections : v.service => v if v.create && v.peering_routes_config }
  network              = local.network_self_link
  peering              = google_service_networking_connection.default[each.key].peering
  import_custom_routes = each.value.import_custom_routes
  export_custom_routes = each.value.export_custom_routes
}

