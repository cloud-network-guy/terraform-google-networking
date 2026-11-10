locals {
  project_id              = lower(trimspace(coalesce(var.project_id, var.project)))
  project                 = local.project_id
  api_prefix              = "https://www.googleapis.com/compute/v1/projects/${local.project}"
  ncc_hub_name            = lower(trimspace(coalesce(var.ncc_hub_name, local.project)))
  ncc_hub_description     = var.ncc_hub_description
  ncc_hub_preset_topology = upper(trimspace(var.ncc_hub_preset_topology))
  export_psc              = var.export_psc
  labels                  = var.labels
  ncc_groups = {
    for k, v in var.ncc_groups :
    k => merge(v, {
      name                 = lower(trimspace(coalesce(v.name, k)))
      hub                  = module.ncc.ncc_hub
      auto_accept_projects = [local.project_id]
      labels               = local.labels
    })
  }
  hybrid_spokes = {
    for k, v in var.hybrid_spokes :
    k => merge(v, {
      labels = local.labels
      group  = "projects/${local.project}/locations/global/hubs/${local.ncc_hub_name}/groups/${v.group}"
      uris = toset(concat(
        tolist(v.uris),
        [for attachment in v.attachments :
          "${local.api_prefix}/regions/${v.location}/interconnectAttachments/${attachment}"
        ],
        [for vpn in v.vpns :
          "${local.api_prefix}/regions/${v.location}/vpnTunnels/${vpn}"
        ]
      ))
    })
  }
  vpc_spokes = {
    for k, v in var.vpc_spokes :
    k => merge(v, {
      labels = local.labels
      uri = coalesce(
        v.uri,
        "projects/${coalesce(v.network_project, local.project)}/global/networks/${v.network}",
      )
    })
  }
}
module "ncc" {
  source                  = "terraform-google-modules/network/google//modules/network-connectivity-center"
  version                 = "~> 18.3"
  project_id              = local.project_id
  ncc_hub_name            = local.ncc_hub_name
  ncc_hub_description     = local.ncc_hub_description
  ncc_hub_preset_topology = local.ncc_hub_preset_topology
  export_psc              = local.export_psc
  ncc_hub_labels          = local.labels
  ncc_groups              = local.ncc_groups
  spoke_labels            = local.labels
  hybrid_spokes           = local.hybrid_spokes
  vpc_spokes              = local.vpc_spokes
}

