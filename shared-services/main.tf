provider "google" {
  project = var.project_id
}


# Set the VPC name prefix and subnet information
locals {
  create = coalesce(var.create, true)
  name   = lower(trimspace(var.network_name))
  subnets = flatten(concat(
    [for i, v in var.regions :
      {
        region         = v.region
        name           = "${local.name}-subnet${i + 1}"
        private_access = var.enable_private_access
        ip_range       = v.main_cidr
        secondary_ranges = concat(
          # GKE Pods Range
          v.gke_pods_cidr != null ? [
            {
              name  = "gke-pods"
              range = v.gke_pods_cidr
            }
          ] : [],
          # GKE Services Ranges
          v.gke_services_cidr != null ? [
            for s in range(0, 29) : {
              name  = format("gke-services-%02s", s)
              range = cidrsubnet(v.gke_services_cidr, var.gke_services_range_length - split("/", v.gke_services_cidr)[1], s)
            }
          ] : [],
        )
        attached_projects = concat(v.attached_projects, var.attached_projects)
        shared_accounts   = concat(v.shared_accounts, var.shared_accounts)
        viewer_accounts   = concat(v.viewer_accounts, var.viewer_accounts)
      }
    ],
    local.create && var.create_proxy_only_subnets == true ? [for i, v in var.regions :
      {
        # Proxy-only subnet for Application ILBs
        region   = v.region
        name     = "${local.name}-x-proxy-only"
        ip_range = v.proxy_only_cidr
        purpose  = var.proxy_only_purpose
      } if v.proxy_only_cidr != null
    ] : [],
    local.create && var.psc_prefix_base != null ? [for p in range(var.num_psc_subnets) :
      {
        # Also add PSC subnets
        name     = "${local.name}-x-psc-${format("%02s", p)}"
        ip_range = cidrsubnet(var.psc_prefix_base, var.psc_subnet_length - split("/", var.psc_prefix_base)[1], p)
        purpose  = var.psc_purpose
      }
    ] : []
  ))
  cloud_routers = [for i, v in var.regions :
    {
      name    = coalesce(v.cloud_router_name, "cloudrouter")
      region  = v.region
      bgp_asn = coalesce(v.cloud_router_bgp_asn, var.cloud_router_bgp_asn)
    }
  ]
  cloud_nats = [for i, v in var.regions :
    {
      name   = coalesce(v.cloud_nat_name, "cloudnat")
      region = v.region
      router = local.name
      static_ips = [for i, v in range(0, var.cloud_nat_num_static_ips) :
        {
          description = "External Static IP for Cloud NAT"
        }
      ]
      min_ports_per_vm = var.cloud_nat_min_ports_per_vm
      max_ports_per_vm = var.cloud_nat_max_ports_per_vm
      log_type         = var.cloud_nat_log_type
    }
  ]
  routes = concat(
    var.enable_private_access == true ? [
      {
        name             = "private-google-access-${local.name}"
        description      = "Explicitly Route PGA range via Default Internet Gateway"
        priority         = 0
        dest_range       = "199.36.153.8/30"
        next_hop_gateway = "default-internet-gateway"
      }
    ] : [],
  )
  ip_ranges = concat(
    local.create && var.enable_service_networking == true ? [
      {
        name     = "servicenetworking-${local.name}"
        ip_range = var.servicenetworking_cidr
      }
    ] : [],
    local.create && var.enable_netapp == true ? [
      {
        name     = "netapp-cv-${local.name}"
        ip_range = var.netapp_cidr
      }
    ] : [],
  )
  service_connections = concat(
    local.create && var.enable_service_networking == true ? [
      {
        name      = "service-networking"
        service   = "servicenetworking.googleapis.com"
        ip_ranges = ["servicenetworking-${local.name}"]
      }
    ] : [],
    local.create && var.enable_netapp == true ? [
      {
        name      = "netapp-gcnv"
        service   = "netapp.servicenetworking.goog"
        ip_ranges = ["netapp-cv-${local.name}"]
      }
    ] : [],
  )
  peerings = []
  firewall_rules = concat([for i, v in var.firewall_rules : merge(v, { name = "${local.name}-${v.name}" })],
    var.enable_private_access == true ? [
      {
        name        = "${local.name}-private-google-access-egress"
        description = "Allow egress to Private Google Access IP Ranges"
        direction   = "EGRESS"
        priority    = 1
        range_types = ["private-googleapis"]
        action      = "allow"
        logging     = false
      }
    ] : [],
    var.create_proxy_only_subnets == true ? [for i, v in var.regions :
      {
        name          = "${local.name}-snat-proxy-only"
        description   = "Allow ingress from Proxy Only / Regional Managed Proxy Subnets"
        direction     = "INGRESS"
        priority      = 1
        action        = "allow"
        source_ranges = [v.proxy_only_cidr]
        allow         = [{ protocol : "tcp", ports : ["1-65535"] }]
        logging       = false
      } if v.proxy_only_cidr != null
    ] : [],
    var.psc_prefix_base != null && var.num_psc_subnets > 0 ? [
      {
        name          = "${local.name}-snat-psc"
        description   = "Allow ingress from PSC Subnets"
        direction     = "INGRESS"
        priority      = 1
        action        = "allow"
        source_ranges = [var.psc_prefix_base]
        allow         = [{ protocol : "tcp", ports : ["1-65535"] }, { protocol : "udp", ports : ["1-65535"] }]
        logging       = false
      },
    ] : [],
  )
}

# Create VPC network and related resources
module "vpc-network" {
  source                  = "../modules/vpc-network"
  project_id              = var.project_id
  create                  = local.create
  name                    = local.name
  description             = null
  mtu                     = var.mtu
  auto_create_subnetworks = false
  global_routing          = true
  subnets                 = local.subnets
  cloud_routers           = local.cloud_routers
  cloud_nats              = [] #local.cloud_nats
  peerings                = local.peerings
  routes                  = local.routes
  ip_ranges               = local.ip_ranges
  service_connections     = local.service_connections
  firewall_rules          = local.firewall_rules
}
