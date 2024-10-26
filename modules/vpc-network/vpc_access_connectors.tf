locals {
  _vpc_access_connectors = [for i, v in coalesce(var.vpc_access_connectors, []) :
    merge(v, {
      create         = local.create ? coalesce(v.create, true) : false
      name           = coalesce(v.name, "connector-${local.name}-${i}")
      region         = coalesce(v.region, var.default_region)
      min_throughput = coalesce(v.min_throughput, 200)
      max_throughput = coalesce(v.max_throughput, 1000)
      min_instances  = coalesce(v.min_instances, 2)
      max_instances  = coalesce(v.max_instances, 10)
      machine_type   = coalesce(v.machine_type, "e2-micro")
    })
  ]
  vpc_access_connectors = [for i, v in local._vpc_access_connectors :
    merge(v, {
      index_key = "${local.project}/${v.region}/${v.name}"
    })
  ]
}

# Serverless VPC Access Connectors
resource "google_vpc_access_connector" "default" {
  for_each      = { for k, v in local.vpc_access_connectors : "${v.region}/${v.name}" => v if v.create }
  project       = local.project
  network       = local.network_self_link
  name          = each.value.name
  region        = each.value.region
  ip_cidr_range = each.value.cidr_range
  dynamic "subnet" {
    for_each = each.value.subnet != null && each.value.cidr_range == null ? [true] : []
    content {
      name       = each.value.subnet
      project_id = each.value.host_project_id
    }
  }
  min_throughput = each.value.min_throughput
  max_throughput = each.value.max_throughput
  min_instances  = each.value.min_instances
  max_instances  = each.value.max_instances
  machine_type   = each.value.machine_type
  #depends_on     = [google_compute_network.default, google_compute_subnetwork.default]
}
