# Allocate Static IP for each Cloud NAT, if required
locals {
  _cloud_nats = [for i, v in coalesce(var.cloud_nats, []) :
    merge(v, {
      create                 = local.create ? coalesce(v.create, true) : false
      name                   = coalesce(v.name, "cloud-nat-${i}")
      region                 = coalesce(v.region, var.default_region)
      num_static_ips         = coalesce(v.num_static_ips, 0)
      static_ips             = coalesce(v.static_ips, [])
      subnets                = coalesce(v.subnets, [])
      enable_dpa             = coalesce(v.enable_dpa, true)
      enable_eim             = coalesce(v.enable_eim, false)
      min_ports_per_vm       = coalesce(v.min_ports_per_vm, v.enable_dpa != false ? 32 : 64)
      max_ports_per_vm       = v.enable_dpa != false ? coalesce(v.max_ports_per_vm, 65536) : null
      log_type               = lower(coalesce(v.log_type, "errors"))
      udp_idle_timeout       = coalesce(v.udp_idle_timeout, 30)
      tcp_est_idle_timeout   = coalesce(v.tcp_established_idle_timeout, 1200)
      tcp_time_wait_timeout  = coalesce(v.tcp_time_wait_timeout, 120)
      tcp_trans_idle_timeout = coalesce(v.tcp_transitory_idle_timeout, 30)
      icmp_idle_timeout      = coalesce(v.icmp_idle_timeout, 30)
      drain_nat_ips          = []
    })
  ]
  __cloud_nats = [for i, v in local._cloud_nats :
    merge(v, {
      router = one([for r in local.cloud_routers :
        google_compute_router.default["${r.region}/${r.name}"].name if r.name == v.router && v.create
      ])
    })
  ]
  ___cloud_nats = [for i, v in local.__cloud_nats :
    merge(v, {
      index_key = "${local.project}/${v.region}/${v.router}/${v.name}"
    }) if v.create
  ]
  nat_addresses = { for i, v in local.___cloud_nats :
    v.index_key => [for a in range(v.num_static_ips) :
      # For each static IP, initialize an empty object
      {
        name        = null
        description = null
        address     = null
      } if v.num_static_ips > 0
    ]
  }
  _cloud_nat_addresses = { for i, v in local.___cloud_nats :
    v.index_key => [for a, nat_address in(length(v.static_ips) > 0 ? v.static_ips : local.nat_addresses[v.index_key]) :
      {
        region      = coalesce(v.region, var.default_region)
        name        = coalesce(nat_address.name, "cloudnat-${local.network_name}-${v.region}-${a}")
        description = nat_address.description
        address     = nat_address.address
      }
    ] if length(v.static_ips) > 0 || v.num_static_ips > 0
  }
  cloud_nat_addresses = flatten([for k, addresses in local._cloud_nat_addresses :
    [for i, address in coalesce(addresses, []) :
      merge(address, {
        create              = local.create
        cloud_nat_index_key = k
        index_key           = "${local.project}/${address.region}/${address.name}"
      })
    ]
  ])
}

# External IP Address Allocations for Cloud NATs using static IP(s)
resource "google_compute_address" "cloud_nat" {
  for_each     = { for i, v in local.cloud_nat_addresses : "${v.region}/${v.name}" => v if v.create }
  project      = local.project
  name         = each.value.name
  description  = each.value.description
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region       = each.value.region
  address      = each.value.address
}

# Cloud NATs (NAT Gateways)
locals {
  log_filter = {
    errors       = "ERRORS_ONLY"
    translations = "TRANSLATIONS_ONLY"
    all          = "ALL"
  }
  ____cloud_nats = [for i, v in local.___cloud_nats :
    merge(v, {
      nat_ip_allocate_option = length(v.static_ips) > 0 || v.num_static_ips > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
    })
  ]
  cloud_nats = [for i, v in local.____cloud_nats :
    merge(v, {
      logging                            = v.log_type == "none" ? false : true
      log_filter                         = upper(lookup(local.log_filter, v.log_type, "ERRORS_ONLY"))
      source_subnetwork_ip_ranges_to_nat = length(v.subnets) > 0 ? "LIST_OF_SUBNETWORKS" : "ALL_SUBNETWORKS_ALL_IP_RANGES"
      source_ip_ranges_to_nat            = ["ALL_IP_RANGES"]
    })
  ]
}

resource "google_compute_router_nat" "default" {
  for_each               = { for i, v in local.cloud_nats : "${v.region}/${v.router}/${v.name}" => v if v.create }
  project                = local.project
  name                   = each.value.name
  router                 = each.value.router
  region                 = each.value.region
  nat_ip_allocate_option = each.value.nat_ip_allocate_option
  nat_ips = [for address in local.cloud_nat_addresses :
    google_compute_address.cloud_nat["${address.region}/${address.name}"].self_link if address.cloud_nat_index_key == each.value.index_key
  ]
  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat
  dynamic "subnetwork" {
    for_each = each.value.subnets
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = each.value.source_ip_ranges_to_nat
    }
  }
  min_ports_per_vm                    = each.value.min_ports_per_vm
  max_ports_per_vm                    = each.value.max_ports_per_vm
  enable_dynamic_port_allocation      = each.value.enable_dpa
  enable_endpoint_independent_mapping = each.value.enable_eim
  log_config {
    enable = each.value.logging
    filter = each.value.log_filter
  }
  udp_idle_timeout_sec             = each.value.udp_idle_timeout
  tcp_established_idle_timeout_sec = each.value.tcp_est_idle_timeout
  tcp_time_wait_timeout_sec        = each.value.tcp_time_wait_timeout
  tcp_transitory_idle_timeout_sec  = each.value.tcp_trans_idle_timeout
  icmp_idle_timeout_sec            = each.value.icmp_idle_timeout
  drain_nat_ips                    = each.value.drain_nat_ips
  depends_on                       = [google_compute_address.cloud_nat, google_compute_router.default]
}
