locals {
  api_prefix        = "https://www.googleapis.com/compute/v1"
  create            = coalesce(var.create, true)
  project           = lower(trimspace(coalesce(var.project_id, var.project)))
  name              = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description       = var.description
  network           = local.create ? one(google_compute_network.default).id : null
  network_self_link = local.create ? one(google_compute_network.default).self_link : null
  network_name      = local.create ? one(google_compute_network.default).name : local.name
  network_fields    = compact([local.name, local.description, local.mtu])
  recreate          = lookup(null_resource.network, join("/", local.network_fields), null) == null ? true : false
}

