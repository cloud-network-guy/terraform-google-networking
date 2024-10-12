
locals {
  # Set object attributes
  instances = [for i, v in var.deployments :
    {
      name                   = v.name
      name_prefix            = var.name_prefix
      region                 = v.region
      zone                   = v.zone
      network                = coalesce(var.network, var.network)
      network_project_id     = try(coalesce(v.host_project_id, var.host_project_id), null)
      subnet                 = v.subnet
      machine_type           = coalesce(v.machine_type, var.machine_type)
      image                  = coalesce(v.image, var.image)
      startup_script         = coalesce(v.startup_script, var.startup_script)
      network_tags           = coalesce(v.network_tags, var.network_tags)
      service_account_scopes = coalesce(v.service_account_scopes, var.service_account_scopes)
    }
  ]
}

# Create the Instances
module "instances" {
  source     = "../modules/instances"
  project_id = var.project_id
  instances  = local.instances
}
