
# VPC Peering Connections
locals {
  _peerings = [for i, peering in coalesce(var.peerings, []) :
    merge(peering, {
      create                              = local.create ? coalesce(peering.create, true) : false
      name                                = coalesce(peering.name, "peering-${local.network_name}-${i}")
      peer_project                        = coalesce(peering.peer_project, local.project)
      peer_network_name                   = coalesce(peering.peer_network, "default")
      import_custom_routes                = coalesce(peering.import_custom_routes, false)
      export_custom_routes                = coalesce(peering.export_custom_routes, false)
      import_subnet_routes_with_public_ip = coalesce(peering.import_subnet_routes_with_public_ip, false)
      export_subnet_routes_with_public_ip = coalesce(peering.export_subnet_routes_with_public_ip, true)
    })
  ]
  peerings = [for peering in local._peerings :
    merge(peering, {
      peer_network = coalesce(
        startswith(peering.peer_network, local.api_prefix) ? peering.peer_network : null,
        startswith(peering.peer_network, "projects/") ? peering.peer_network : null,
        "projects/${peering.peer_project}/global/networks/${peering.peer_network_name}"
      )
      index_key = "${local.project}/${local.network_name}/${peering.name}"
    }) if local.recreate == false
  ]
}
resource "google_compute_network_peering" "default" {
  for_each                            = { for k, v in local.peerings : v.name => v if v.create }
  network                             = local.network_self_link
  name                                = each.value.name
  peer_network                        = each.value.peer_network
  import_custom_routes                = each.value.import_custom_routes
  export_custom_routes                = each.value.export_custom_routes
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  timeouts {
    create = null
    delete = null
    update = null
  }
}

