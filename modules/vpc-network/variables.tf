variable "create" {
  type    = bool
  default = true
}
variable "project_id" {
  type    = string
  default = null
}
variable "project" {
  type    = string
  default = null
}
variable "name" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "mtu" {
  type    = number
  default = 0
}
variable "global_routing" {
  type    = bool
  default = false
}
variable "routing_mode" {
  type    = string
  default = "REGIONAL"
}
variable "network_firewall_policy_enforcement_order" {
  type    = string
  default = "AFTER_CLASSIC_FIREWALL"
}
variable "auto_create_subnetworks" {
  type    = bool
  default = false
}
variable "enable_ula_internal_ipv6" {
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
variable "default_region" {
  type    = string
  default = null
}
variable "subnets" {
  type = list(object({
    create                   = optional(bool, true)
    name                     = optional(string)
    description              = optional(string)
    region                   = optional(string)
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
      name        = optional(string)
      description = optional(string)
      address     = optional(string)
      target      = string
    })))
  }))
  default = []
}
variable "routes" {
  type = list(object({
    create            = optional(bool, true)
    name              = optional(string)
    description       = optional(string)
    dest_range        = optional(string)
    dest_ranges       = optional(list(string))
    priority          = optional(number, 1000)
    tags              = optional(list(string))
    next_hop          = optional(string)
    next_hop_gateway  = optional(string)
    next_hop_instance = optional(string)
    next_hop_zone     = optional(string)
  }))
  default = []
}
variable "peerings" {
  type = list(object({
    create                              = optional(bool, true)
    name                                = optional(string)
    peer_project                        = optional(string)
    peer_network                        = optional(string)
    import_custom_routes                = optional(bool, false)
    export_custom_routes                = optional(bool, false)
    import_subnet_routes_with_public_ip = optional(bool, false)
    export_subnet_routes_with_public_ip = optional(bool, true)
  }))
  default = []
}
variable "ip_ranges" {
  type = list(object({
    create      = optional(bool, true)
    name        = optional(string)
    description = optional(string)
    ip_range    = string
    purpose     = optional(string, "VPC_PEERING")
  }))
  default = []
}
variable "service_connections" {
  type = list(object({
    create               = optional(bool, true)
    name                 = optional(string)
    service              = optional(string)
    ip_ranges            = list(string)
    import_custom_routes = optional(bool, false)
    export_custom_routes = optional(bool, false)
  }))
  default = []
}
variable "cloud_routers" {
  type = list(object({
    create                        = optional(bool, true)
    name                          = optional(string)
    description                   = optional(string)
    encrypted_interconnect_router = optional(bool)
    region                        = optional(string)
    enable_bgp                    = optional(bool)
    bgp_asn                       = optional(number)
    bgp_keepalive_interval        = optional(number)
    advertised_groups             = optional(list(string))
    advertised_ip_ranges = optional(list(object({
      create      = optional(bool)
      range       = string
      description = optional(string)
    })))
  }))
  default = []
}
variable "cloud_nats" {
  type = list(object({
    create         = optional(bool, true)
    name           = optional(string)
    region         = optional(string)
    router         = optional(string)
    subnets        = optional(list(string))
    num_static_ips = optional(number)
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
  }))
  default = []
}
variable "vpc_access_connectors" {
  type = list(object({
    create         = optional(bool, true)
    name           = optional(string)
    region         = optional(string)
    cidr_range     = optional(string)
    subnet         = optional(string)
    min_throughput = optional(number)
    max_throughput = optional(number)
    min_instances  = optional(number)
    max_instances  = optional(number)
    machine_type   = optional(string)
  }))
  default = []
}
variable "firewall_rules" {
  type = list(object({
    create                  = optional(bool, true)
    network                 = optional(string)
    name                    = optional(string)
    description             = optional(string)
    priority                = optional(number, 1000)
    logging                 = optional(bool, false)
    direction               = optional(string)
    ranges                  = optional(list(string))
    range                   = optional(string)
    source_ranges           = optional(list(string))
    destination_ranges      = optional(list(string))
    range_types             = optional(list(string), [])
    range_type              = optional(string)
    protocol                = optional(string)
    protocols               = optional(list(string))
    port                    = optional(number)
    ports                   = optional(list(number), [])
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

