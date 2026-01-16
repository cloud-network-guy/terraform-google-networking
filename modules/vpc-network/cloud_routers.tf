
# Cloud Routers
locals {
  _cloud_routers = [for i, router in coalesce(var.cloud_routers, []) :
    {
      create                        = local.create ? coalesce(router.create, true) : false
      name                          = coalesce(router.name, "rtr-${local.network_name}}${i}")
      description                   = router.description
      region                        = coalesce(router.region, var.default_region)
      enable_bgp                    = router.enable_bgp
      bgp_asn                       = router.bgp_asn
      bgp_keepalive_interval        = router.bgp_keepalive_interval
      advertise_mode                = length(coalesce(router.advertised_ip_ranges, [])) > 0 ? "CUSTOM" : "DEFAULT"
      advertised_groups             = coalesce(router.advertised_groups, [])
      advertised_ip_ranges          = coalesce(router.advertised_ip_ranges, [])
      encrypted_interconnect_router = coalesce(router.encrypted_interconnect_router, false)
    }
  ]
  __cloud_routers = [for router in local._cloud_routers :
    merge(router, {
      enable_bgp = coalesce(
        router.enable_bgp,
        # Auto-enable if an ASN is configured
        router.bgp_asn != null ? true : false,  
        # Auto-enable if BGP advertised groups or custom ranges are configured
        length(concat(router.advertised_groups, router.advertised_ip_ranges)) > 0 ? true : false
      )
    })
  ]
  cloud_routers = [for router in local.__cloud_routers :
    merge(router, {
      bgp_asn                = router.enable_bgp ? coalesce(router.bgp_asn, 64512) : null
      bgp_keepalive_interval = router.enable_bgp ? coalesce(router.bgp_keepalive_interval, 20) : null
      index_key              = "${local.project}/${router.region}/${router.name}"
    })
  ]
}
resource "google_compute_router" "default" {
  for_each                      = { for i, v in local.cloud_routers : "${v.region}/${v.name}" => v if v.create }
  project                       = local.project
  network                       = local.network_self_link
  name                          = each.value.name
  description                   = each.value.description
  region                        = each.value.region
  encrypted_interconnect_router = each.value.encrypted_interconnect_router
  dynamic "bgp" {
    for_each = each.value.enable_bgp ? [true] : []
    content {
      asn                = each.value.bgp_asn
      keepalive_interval = each.value.bgp_keepalive_interval
      advertise_mode     = each.value.advertise_mode
      advertised_groups  = each.value.advertised_groups
      dynamic "advertised_ip_ranges" {
        for_each = each.value.advertised_ip_ranges
        content {
          range       = advertised_ip_ranges.value.range
          description = advertised_ip_ranges.value.description
        }
      }
    }
  }
  timeouts {
    create = null
    delete = null
    update = null
  }
}

