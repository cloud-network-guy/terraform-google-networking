
resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

locals {
  api_prefix   = "https://www.googleapis.com/compute/v1"
  create       = coalesce(var.create, true)
  project      = lower(trimspace(coalesce(var.project_id, var.project)))
  name         = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  description  = var.description != null ? trimspace(var.description) : null
  is_regional  = var.region != null ? true : false
  is_global    = !local.is_regional
  region       = local.is_regional ? lower(trimspace(var.region)) : "global"
  host_project = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
  network = var.network != null ? trimspace(coalesce(
    startswith(var.network, local.api_prefix) ? var.network : null,
    startswith(var.network, "projects/") ? "${local.api_prefix}/${var.network}" : null,
    "projects/${local.host_project}/global/networks/${var.network}",
  )) : null
  subnetwork = var.subnetwork != null ? trimspace(coalesce(
    startswith(var.subnetwork, local.api_prefix) ? var.subnetwork : null,
    startswith(var.subnetwork, "projects/", ) ? "${local.api_prefix}/${var.subnetwork}" : null,
    "projects/${local.host_project}/regions/${local.region}/subnetworks/${var.subnetwork}",
  )) : null
  location  = local.region
  type      = "SECURE_WEB_GATEWAY"
  addresses = coalesce(var.addresses, compact([var.address]))
  ports     = coalesce(var.ports, compact([var.port]))
  labels    = var.labels != null ? { for k, v in var.labels : k => lower(replace(v, " ", "_")) } : null
  scope     = local.location
}

# Gateway Security Policy
resource "google_network_security_gateway_security_policy" "default" {
  count                 = local.create ? 1 : 0
  name                  = local.name
  project               = local.project
  location              = local.region
  description           = local.description
  tls_inspection_policy = null
}

# Network Services Gateway
resource "google_network_services_gateway" "default" {
  count                                = local.create ? 1 : 0
  name                                 = local.name
  description                          = local.description
  project                              = local.project
  location                             = local.location
  addresses                            = local.addresses
  type                                 = local.type
  labels                               = local.labels
  ports                                = local.type == "SECURE_WEB_GATEWAY" ? slice(local.ports, 0, 1) : local.ports
  scope                                = local.scope
  certificate_urls                     = []
  gateway_security_policy              = one(google_network_security_gateway_security_policy.default).id
  network                              = local.network
  subnetwork                           = local.subnetwork
  delete_swg_autogen_router_on_destroy = true
}

locals {
  url_list = [
    for i, v in coalesce(var.url_list, []) :
    substr(v, 0, 1) == "." ? "*${substr(v, 1, -1)}" : v
  ]
}
resource "google_network_security_url_lists" "default" {
  count       = length(local.url_list) > 0 ? 1 : 0
  project     = local.project
  name        = local.name
  location    = local.location
  description = local.description
  values      = local.url_list
}

locals {
  url_list_name = one(google_network_security_url_lists.default).name
  url_list_id   = one(google_network_security_url_lists.default).id
  rules = concat(
    # Iterate over manual rules
    [for i, v in coalesce(var.rules, []) : merge(v, {
      create              = coalesce(v.create, local.create)
      enabled             = coalesce(v.enabled, true)
      name                = lower(trimspace(v.name != null ? v.name : "rule-${i}"))
      description         = v.description != null ? trimspace(v.description) : null
      priority            = coalesce(v.priority, i)
      session_matcher     = trimspace(v.session_matcher)
      application_matcher = ""
      basic_profile       = upper(trimspace(coalesce(v.basic_profile, "ALLOW")))
    })],
    length(local.url_list) > 0 ? [
      {
        create              = local.create
        enabled             = true
        name                = "allow-hosts-in-url-list"
        description         = "Allow Hosts that match the URL List '${local.url_list_name}'"
        priority            = 999
        session_matcher     = local.create ? "inUrlList(host(), '${local.url_list_id}')" : ""
        application_matcher = ""
        basic_profile       = "ALLOW"
      }
    ] : []
  )
}

resource "null_resource" "rules" {
  for_each = { for i, v in local.rules : v.name => v if v.create }
}
resource "google_network_security_gateway_security_policy_rule" "default" {
  for_each                = { for i, v in local.rules : v.name => v if v.create }
  project                 = local.project
  location                = local.location
  gateway_security_policy = one(google_network_security_gateway_security_policy.default).name
  name                    = each.value.name
  description             = each.value.description
  enabled                 = each.value.enabled
  priority                = each.value.priority
  session_matcher         = each.value.session_matcher
  application_matcher     = each.value.application_matcher
  basic_profile           = each.value.basic_profile
  depends_on              = [null_resource.rules]
}