locals {
  create          = coalesce(var.create, true)
  project         = lower(trimspace(coalesce(var.project_id, var.project)))
  host_project_id = lower(trimspace(coalesce(var.host_project_id, var.host_project, local.project)))
}

# Enable Shared VPC Host Project, if not already done
resource "google_compute_shared_vpc_host_project" "default" {
  count   = var.enable_shared_vpc_host_project ? 1 : 0
  project = var.project_id
}

# Form locals to pass to the VPC network module
locals {
  name_prefix = coalesce(var.name_prefix, var.name)
  peerings = [
    for i, peering in var.peerings :
    merge(peering, {
      name         = try(coalesce(peering.name, peering.peer_network_name), null)
      peer_network = coalesce(peering.peer_network_link, peering.peer_network_name)
      peer_project = peering.peer_project_id
    })
  ]
  routes = [
    for i, route in var.routes :
    merge(route, {
      name = coalesce(route.name, "${local.name_prefix}-${i}")
    })
  ]
  ip_ranges = [
    for i, ip_range in var.ip_ranges :
    merge(ip_range, {
      name = coalesce(ip_range.name, "${local.name_prefix}-${i}")
    })
  ]
  service_connections = [
    for i, service_connection in var.service_connections :
    merge(service_connection, {
      name = coalesce(service_connection.name, "${local.name_prefix}-${i}")
    })
  ]
  firewall_rules = [
    for i, firewall_rule in var.firewall_rules :
    merge(firewall_rule, {
      name = coalesce(firewall_rule.name, "${local.name_prefix}-${i}")
    })
  ]
  subnets = concat(
    flatten([for k, region in var.regions :
      [for i, subnet in coalesce(region.subnets, []) :
        merge(subnet, {
          name              = coalesce(subnet.name, "${local.name_prefix}-${k}-subnet${i + 1}")
          description       = subnet.description
          region            = k
          ip_range          = subnet.ip_range
          private_access    = coalesce(subnet.private_access, var.subnet_private_access, false)
          psc_endpoints     = coalesce(subnet.psc_endpoints, [])
          attached_projects = coalesce(subnet.attached_projects, [])
          shared_accounts   = coalesce(subnet.shared_accounts, [])
          viewer_accounts   = coalesce(subnet.viewer_accounts, [])
        })
      ]
    ]),
    # Add HTTPS ILB Proxy-Only Subnet, if configured to do so
    [for k, region in var.regions :
      {
        name     = coalesce(region.lb_subnet_name, "${local.name_prefix}-${k}-${var.lb_subnet_suffix}")
        region   = k
        ip_range = region.lb_subnet_ip_range
        purpose  = "INTERNAL_HTTPS_LOAD_BALANCER"
      } if coalesce(region.create_lb_subnet, var.create_lb_subnets) == true
    ],
  )
  cloud_routers = concat(
    # Manually specified Cloud Routers
    flatten([for k, region in var.regions :
      [for cloud_router in coalesce(region.cloud_routers, []) :
        merge(cloud_router, {
          name    = coalesce(cloud_router.name, "${local.name_prefix}-${k}")
          region  = k
          bgp_asn = try(coalesce(cloud_router.bgp_asn, var.cloud_router_bgp_asn), null)
        })
      ]
    ]),
    # Auto Created Cloud Routers
    [for k, region in var.regions :
      {
        name    = "${local.name_prefix}-${k}"
        region  = k
        bgp_asn = var.cloud_router_bgp_asn
      } if coalesce(region.create_cloud_router, var.create_cloud_routers) == true
    ],
  )
  cloud_nats = concat(
    # Manually specified Cloud NATs
    flatten([for k, region in var.regions :
      [for cloud_nat in coalesce(region.cloud_nats, []) :
        merge(cloud_nat, {
          name             = coalesce(cloud_nat.name, "${coalesce(var.cloud_nat_name_prefix, local.name_prefix)}-${k}")
          region           = k
          router           = coalesce(cloud_nat.cloud_router_name, cloud_nat.cloud_router, "${local.name_prefix}-${k}")
          min_ports_per_vm = coalesce(cloud_nat.min_ports_per_vm, var.cloud_nat_min_ports_per_vm)
          max_ports_per_vm = coalesce(cloud_nat.max_ports_per_vm, var.cloud_nat_max_ports_per_vm)
          log_type         = coalesce(cloud_nat.log_type, var.cloud_nat_log_type)
        })
      ]
    ]),
    # Auto Created Cloud NATs
    [for k, region in var.regions :
      {
        name             = "${coalesce(var.cloud_nat_name_prefix, local.name_prefix)}-${k}"
        region           = k
        router           = "${local.name_prefix}-${k}"
        min_ports_per_vm = var.cloud_nat_min_ports_per_vm
        max_ports_per_vm = var.cloud_nat_max_ports_per_vm
        log_type         = var.cloud_nat_log_type
        static_ips       = var.cloud_nat_use_static_ip ? [{ name = "${var.cloud_nat_name_prefix != null ? var.cloud_nat_name_prefix : local.name_prefix}-${k}" }] : []
      } if coalesce(region.create_cloud_nat, var.create_cloud_nats) == true && length(coalesce(region.cloud_nats, [])) == 0
    ]
  )
  vpc_access_connectors = flatten([for k, region in var.regions :
    [for vpc_access_connector in coalesce(region.vpc_access_connectors, []) :
      merge(vpc_access_connector, {
        region = k
      })
    ]
  ])
  cloud_vpn_gateways = concat(
    # Manually specified
    flatten([for k, region in var.regions :
      [for cloud_vpn_gateway in coalesce(region.cloud_vpn_gateways, []) :
        merge(cloud_vpn_gateway, {
          name    = coalesce(cloud_vpn_gateway.name, "${local.name_prefix}-${k}")
          network = var.name
          region  = k
        })
      ]
    ]),
    [for k, region in var.regions :
      {
        name    = "${local.name_prefix}-${k}"
        network = var.name
        region  = k
      } if coalesce(region.create_cloud_vpn_gateway, var.create_cloud_vpn_gateways) == true
    ]
  )
}


# Create VPC network and related resources
module "vpc-network" {
  source                  = "../modules/vpc-network"
  create                  = var.create
  project_id              = var.project_id
  name                    = local.name_prefix
  description             = var.description
  mtu                     = var.mtu
  auto_create_subnetworks = var.auto_create_subnetworks
  global_routing          = var.enable_global_routing
  subnets                 = local.subnets
  cloud_routers           = local.cloud_routers
  cloud_nats              = local.cloud_nats
  peerings                = local.peerings
  routes                  = local.routes
  ip_ranges               = local.ip_ranges
  service_connections     = local.service_connections
  vpc_access_connectors   = local.vpc_access_connectors
  firewall_rules          = local.firewall_rules
}

# Cloud VPN Gateways
module "cloud-vpn-gateway" {
  source             = "../modules/hybrid-networking"
  project_id         = var.project_id
  cloud_vpn_gateways = local.cloud_vpn_gateways
}


# Shared VPC Permissions
locals {
  shared_subnetworks = [for subnet in local.subnets :
    {
      id                = one([for s in module.vpc-network.subnets : s.id if s.name == subnet.name && s.region == subnet.region])
      name              = one([for s in module.vpc-network.subnets : s.name if s.name == subnet.name && s.region == subnet.region])
      region            = one([for s in module.vpc-network.subnets : s.region if s.name == subnet.name && s.region == subnet.region])
      purpose           = one([for s in module.vpc-network.subnets : s.purpose if s.name == subnet.name && s.region == subnet.region])
      attached_projects = concat(lookup(subnet, "attached_projects", []), var.attached_projects)
      shared_accounts   = concat(lookup(subnet, "shared_accounts", []), var.shared_accounts)
      viewer_accounts   = concat(lookup(subnet, "viewer_accounts", []), var.viewer_accounts)
    }
  ]
}
module "shared-vpc" {
  source          = "../modules/shared-vpc"
  host_project_id = var.project_id
  network         = module.vpc-network.name
  subnetworks     = [for s in local.shared_subnetworks : s if s.purpose == "PRIVATE"]
}

# PSC Consumer Endpoints
locals {
  psc_endpoints = flatten([for s, subnet in local.subnets :
    [for e, endpoint in lookup(subnet, "psc_endpoints", []) :
      {
        name         = coalesce(endpoint.name, endpoint.target_name, "psc-${e + 1}")
        address      = endpoint.ip_address
        address_name = endpoint.ip_address_name
        region       = subnet.region
        subnetwork   = subnet.name
        target = coalesce(endpoint.target,
          endpoint.target_project_id != null ? "projects/${endpoint.target_project_id}/regions/${subnet.region}/serviceAttachments/${endpoint.target_name}" : null,
          "error"
        )
        global_access = coalesce(endpoint.global_access, false)
      }
    ]
  ])
}
module "psc-endpoints" {
  source        = "../modules/forwarding-rule"
  for_each      = { for k, v in local.psc_endpoints : "${v.region}/${v.name}" => v }
  project_id    = var.project_id
  network       = module.vpc-network.self_link
  name          = each.value.name
  address       = each.value.address
  address_name  = each.value.address_name
  region        = each.value.region
  subnetwork    = each.value.subnetwork
  target        = each.value.target
  global_access = each.value.global_access
  depends_on    = [module.vpc-network]
}
