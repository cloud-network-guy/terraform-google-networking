variable "name" {
  type        = string
  description = "Name of VPC Network"
}
variable "description" {
  type        = string
  description = "Description of VPC Network"
  default     = null
}
variable "create" {
  type        = bool
  description = "Whether to create this network or not"
  default     = true
}
variable "project_id" {
  type    = string
  default = null
}
varible "project" {
  type    = string
  default = null
}
variable "org_id" {
  type        = string
  description = "GCP Org ID"
  default     = null
}
variable "mtu" {
  description = "MTU for the VPC network: 1460 (default) or 1500"
  type        = number
  default     = 0
}
variable "enable_shared_vpc_host_project" {
  description = "Enable Shared VPC Host Project"
  type        = bool
  default     = false
}
variable "enable_global_routing" {
  description = "Enable Global Routing (default is Regional)"
  type        = bool
  default     = false
}
variable "auto_create_subnetworks" {
  type    = bool
  default = false
}
variable "attached_projects" {
  type    = list(string)
  default = []
}
variable "shared_accounts" {
  type    = list(string)
  default = []
}
variable "viewer_accounts" {
  type    = list(string)
  default = []
}
variable "name_prefix" {
  type        = string
  description = "Name Prefix to apply to all components of this VPC network"
  default     = null
}
variable "subnet_private_access" {
  type        = bool
  description = "Enable Private Google Access on all subnets (can be overridden at subnet level)"
  default     = false
}
variable "create_cloud_routers" {
  type        = bool
  description = "Create Cloud Router for every region"
  default     = false
}
variable "cloud_router_bgp_asn" {
  type        = number
  description = "BGP AS Number for Cloud Routers (can be overridden at object level)"
  default     = null
}
variable "create_lb_subnets" {
  type        = bool
  description = "Create Internal Load Balancer (proxy-only) subnets for each region"
  default     = false
}
variable "lb_subnet_suffix" {
  type        = string
  description = "Suffix to apply to LB subnets"
  default     = "ilb"
}
variable "create_cloud_nats" {
  type        = bool
  description = "Create Cloud NAT for every region"
  default     = false
}
variable "cloud_nat_use_static_ip" {
  type        = bool
  description = "Allocate and use a Static IP for each Cloud NAT"
  default     = false
}
variable "cloud_nat_name_prefix" {
  type        = string
  description = "Name Prefix to Apply to Cloud NATs"
  default     = null
}
variable "cloud_nat_min_ports_per_vm" {
  type        = number
  description = "Min number of ports to for Cloud NAT to allocate for each VM"
  default     = 32
}
variable "cloud_nat_max_ports_per_vm" {
  type        = number
  description = "Max number of ports to for Cloud NAT to allocate for each VM"
  default     = 65536
}
variable "cloud_nat_log_type" {
  type        = string
  description = "Type of logging to do for Cloud NAT"
  default     = "error"
}
variable "create_cloud_vpn_gateways" {
  type        = bool
  description = "Create Cloud VPN Gateway for every region"
  default     = false
}
variable "peerings" {
  type = list(object({
    create                              = optional(bool, true)
    project_id                          = optional(string)
    name                                = optional(string)
    peer_project_id                     = optional(string)
    peer_network_name                   = optional(string)
    peer_network_link                   = optional(string)
    import_custom_routes                = optional(bool)
    export_custom_routes                = optional(bool)
    import_subnet_routes_with_public_ip = optional(bool)
    export_subnet_routes_with_public_ip = optional(bool)
  }))
  default = []
}
variable "routes" {
  type = list(object({
    create        = optional(bool, true)
    project_id    = optional(string)
    name          = optional(string)
    description   = optional(string)
    dest_range    = optional(string)
    dest_ranges   = optional(list(string))
    priority      = optional(number)
    tags          = optional(list(string))
    next_hop      = optional(string)
    next_hop_zone = optional(string)
  }))
  default = []
}
variable "ip_ranges" {
  type = list(object({
    create      = optional(bool, true)
    project_id  = optional(string)
    name        = optional(string)
    description = optional(string)
    ip_range    = string
  }))
  default = []
}
variable "service_connections" {
  type = list(object({
    create               = optional(bool, true)
    project_id           = optional(string)
    name                 = optional(string)
    service              = optional(string)
    ip_ranges            = list(string)
    import_custom_routes = optional(bool)
    export_custom_routes = optional(bool)
  }))
  default = []
}

variable "regions" {
  type = map(object({
    create_cloud_router      = optional(bool)
    create_cloud_nat         = optional(bool)
    create_lb_subnet         = optional(bool)
    create_cloud_vpn_gateway = optional(bool)
    lb_subnet_suffix         = optional(string)
    lb_subnet_name           = optional(string)
    lb_subnet_ip_range       = optional(string)
    subnets = optional(list(object({
      create                   = optional(bool, true)
      project_id               = optional(string)
      name                     = optional(string)
      description              = optional(string)
      stack_type               = optional(string)
      ip_range                 = string
      purpose                  = optional(string)
      role                     = optional(string)
      private_access           = optional(bool)
      flow_logs                = optional(bool)
      log_aggregation_interval = optional(string)
      log_sampling_rate        = optional(number)
      attached_projects        = optional(list(string))
      shared_accounts          = optional(list(string))
      viewer_accounts          = optional(list(string))
      secondary_ranges = optional(list(object({
        name  = optional(string)
        range = string
      })))
      psc_endpoints = optional(list(object({
        target            = optional(string)
        target_project_id = optional(string)
        target_name       = optional(string)
        name              = optional(string)
        ip_address        = optional(string)
        ip_address_name   = optional(string)
        global_access     = optional(bool)
      })))
    })))
    cloud_routers = optional(list(object({
      create                        = optional(bool, true)
      project_id                    = optional(string)
      name                          = optional(string)
      description                   = optional(string)
      encrypted_interconnect_router = optional(bool)
      bgp_asn                       = optional(number)
      bgp_keepalive_interval        = optional(number)
      advertised_groups             = optional(list(string))
      advertised_ip_ranges = optional(list(object({
        create      = optional(bool)
        range       = string
        description = optional(string)
      })))
    })))
    cloud_nats = optional(list(object({
      create            = optional(bool, true)
      project_id        = optional(string)
      name              = optional(string)
      cloud_router      = optional(string)
      cloud_router_name = optional(string)
      subnets           = optional(list(string))
      num_static_ips    = optional(number)
      static_ips = optional(list(object({
        name        = optional(string)
        description = optional(string)
        address     = optional(string)
      })))
      log_type                     = optional(string)
      enable_dpa                   = optional(bool)
      min_ports_per_vm             = optional(number)
      max_ports_per_vm             = optional(number)
      enable_eim                   = optional(bool)
      udp_idle_timeout             = optional(number)
      tcp_established_idle_timeout = optional(number)
      tcp_time_wait_timeout        = optional(number)
      tcp_transitory_idle_timeout  = optional(number)
      icmp_idle_timeout            = optional(number)
    })))
    vpc_access_connectors = optional(list(object({
      create             = optional(bool, true)
      project_id         = optional(string)
      network_project_id = optional(string)
      name               = optional(string)
      region             = optional(string)
      cidr_range         = optional(string)
      subnet             = optional(string)
      min_throughput     = optional(number)
      max_throughput     = optional(number)
      min_instances      = optional(number)
      max_instances      = optional(number)
      machine_type       = optional(string)
    })))
    cloud_vpn_gateways = optional(list(object({
      create     = optional(bool, true)
      project_id = optional(string)
      name       = optional(string)
    })))
  }))
  default = {}
}
variable "firewall_rules" {
  type = list(object({
    create                  = optional(bool, true)
    project_id              = optional(string)
    name                    = optional(string)
    name_prefix             = optional(string)
    short_name              = optional(string)
    description             = optional(string)
    network                 = optional(string)
    network_name            = optional(string)
    priority                = optional(number)
    logging                 = optional(bool)
    direction               = optional(string)
    ranges                  = optional(list(string))
    range                   = optional(string)
    source_ranges           = optional(list(string))
    destination_ranges      = optional(list(string))
    range_types             = optional(list(string))
    range_type              = optional(string)
    protocol                = optional(string)
    protocols               = optional(list(string))
    port                    = optional(number)
    ports                   = optional(list(number))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    action                  = optional(string)
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    enforcement = optional(bool)
    disabled    = optional(bool)
  }))
  default = []
}
