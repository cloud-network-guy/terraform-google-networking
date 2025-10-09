variable "create" {
  type    = bool
  default = true
}
variable "name_prefix" {
  description = "Name Prefix to give to all resources"
  type        = string
  default     = "vpc"
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "project" {
  type    = string
  default = null
}
variable "network_name" {
  type        = string
  description = "Name of VPC Network"
  default     = null
}
variable "mtu" {
  type        = number
  description = "IP MTU"
  default     = null
}
variable "region" {
  description = "GCP Region Name"
  type        = string
}
variable "enable_private_access" {
  description = "Enable Google Private Access on all Subnets"
  type        = bool
  default     = false
}
variable "enable_service_networking" {
  description = "Enable PSA Connection to Service Networking"
  type        = bool
  default     = false
}
variable "enable_netapp_cv" {
  description = "Enable PSA Connection NetApp Cloud Volumes"
  type        = bool
  default     = false
}
variable "enable_netapp_gcnv" {
  description = "Enable PSA Connection NetApp Cloud Volumes"
  type        = bool
  default     = true
}
variable "cloud_router_bgp_asn" {
  type    = string
  default = 64512
}
variable "cloud_nat_num_static_ips" {
  type    = number
  default = 1
}
variable "cloud_nat_min_ports_per_vm" {
  type    = number
  default = 128
}
variable "cloud_nat_max_ports_per_vm" {
  type    = number
  default = 4096
}
variable "cloud_nat_log_type" {
  type    = string
  default = "errors"
}
variable "gke_services_range_length" {
  type    = number
  default = 22
}
variable "create_proxy_only_subnet" {
  type    = bool
  default = true
}
variable "proxy_only_cidr" {
  type    = string
  default = null
}
variable "proxy_only_purpose" {
  type    = string
  default = "REGIONAL_MANAGED_PROXY"
}
variable "psc_prefix_base" {
  type    = string
  default = null
}
variable "psc_subnet_length" {
  type    = number
  default = 28
}
variable "num_psc_subnets" {
  type    = number
  default = 16
}
variable "psc_purpose" {
  type    = string
  default = "PRIVATE_SERVICE_CONNECT"
}
variable "servicenetworking_cidr" {
  type    = string
  default = null
}
variable "netapp_cidr" {
  type    = string
  default = null
}
variable "cloud_nat_routes" {
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
variable "attached_projects" {
  type    = list(string)
  default = []
}
variable "subnets" {
  type = list(object({
    main_cidr         = string
    gke_pods_cidr     = string
    gke_services_cidr = string
    region            = optional(string)
    name              = optional(string)
    attached_projects = optional(list(string), [])
    shared_accounts   = optional(list(string), [])
    viewer_accounts   = optional(list(string), [])
  }))
  default = []
}
variable "allow_internal_ingress" {
  type    = bool
  default = true
}
variable "allow_external_ingress" {
  type    = bool
  default = false
}
variable "log_internal_ingress" {
  type    = bool
  default = false
}
variable "log_external_ingress" {
  type    = bool
  default = true
}
variable "allow_internal_egress" {
  type    = bool
  default = true
}
variable "allow_external_egress" {
  type    = bool
  default = true
}
variable "log_internal_egress" {
  type    = bool
  default = false
}
variable "log_external_egress" {
  type    = bool
  default = true
}
variable "require_regional_network_tag" {
  type    = bool
  default = false
}
variable "internal_ips" {
  type    = list(string)
  default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10"]
}
variable "hub_vpc" {
  type = object({
    project_id           = optional(string)
    network              = optional(string, "default")
    bgp_asn              = optional(number, 64512)
    cloud_router         = optional(string)
    cloud_vpn_gateway    = optional(string)
    advertised_ip_ranges = optional(list(string), ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])
  })
}
variable "routes" {
  type = list(object({
    name        = optional(string)
    description = optional(string)
    priority    = optional(number)
    dest_range  = optional(string)
    dest_ranges = optional(list(string))
    next_hop    = optional(string)
  }))
  default = []
}
variable "firewall_rules" {
  type = list(object({
    name                    = optional(string)
    description             = optional(string)
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
variable "psc_endpoints" {
  type = list(object({
    project_id             = optional(string)
    name                   = optional(string)
    description            = optional(string)
    subnet                 = optional(string)
    ip_address             = optional(string)
    ip_address_name        = optional(string)
    ip_address_description = optional(string)
    target                 = string
    global_access          = optional(bool)
  }))
  default = []
}
