provider "google" {
  project = local.project_id
}

provider "google-beta" {
  project               = local.project_id
  billing_project       = local.project_id
  user_project_override = true
}

resource "random_string" "name" {
  count   = var.name == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}

# Set the VPC name prefix and subnet information
locals {
  create     = coalesce(var.create, true)
  project_id = lower(trimspace(var.project_id))
  url_prefix = "https://www.googleapis.com/compute/v1"
  regions    = [for region in coalesce(var.regions, []) : lower(trimspace(region))]
  name       = lower(trimspace(var.name != null ? var.name : one(random_string.name).result))
  subnets = [for r, region in local.regions : {
    name     = "psc-landing"
    region   = region
    ip_range = "192.168.${r}.0/24"
  }]
  cloud_routers = [for r, region in local.regions : {
    name    = "psc-landing"
    region  = region
    bgp_asn = var.cloud_router_bgp_asn
  }]
}

# VPC network and related resources
module "vpc-network" {
  source                  = "../modules/vpc-network"
  project_id              = local.project_id
  create                  = local.create
  name                    = local.name
  description             = null
  mtu                     = var.mtu
  auto_create_subnetworks = false
  global_routing          = true
  subnets                 = local.subnets
  cloud_routers           = local.cloud_routers
  peerings                = []
}

# DNS Policy w/ Inbound Forwarding enabled
module "dns-policy" {
  source                    = "../modules/dns-policy"
  project_id                = local.project_id
  create                    = local.create
  name                      = local.name
  logging                   = true
  enable_inbound_forwarding = true
  networks                  = [module.vpc-network.self_link]
}

locals {
  cloud_vpn_gateways = local.create ? [for region in local.regions :
    {
      name    = "psc-landing" #local.name
      network = local.name
      region  = region
    }
  ] : []
  vpns = local.create ? [] : []
}
# Create VPN connection
module "vpns" {
  source             = "../modules/hybrid-networking"
  project_id         = local.project_id
  cloud_vpn_gateways = local.cloud_vpn_gateways
  vpns               = local.vpns
  depends_on         = [module.vpc-network]
}

# PSC Consumer Endpoints
locals {
  # Create PSC Consumer Endpoints inside each region for each service
  psc_endpoints = [for i, v in var.psc_endpoints :
    merge(v, {
      network = local.name
      region  = local.regions[0]
      target  = startswith(v.target, local.url_prefix) ? v.target : "${local.url_prefix}/${v.target}"
    })
  ]
}
module "psc-endpoints" {
  source              = "../modules/forwarding-rule"
  for_each            = { for k, v in local.psc_endpoints : "${v.project_id}/${v.region}/${v.name}" => v }
  create              = local.create
  project_id          = local.project_id
  name                = each.value.name
  description         = each.value.description
  region              = each.value.region
  address             = each.value.ip_address
  address_name        = each.value.ip_address_name
  address_description = each.value.ip_address_description
  network             = each.value.network
  subnetwork          = each.value.subnet
  target              = each.value.target
  global_access       = false
  depends_on          = [module.vpc-network]
}
