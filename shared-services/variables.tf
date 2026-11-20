variable "create" {
  type    = bool
  default = true
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "network_name" {
  type        = string
  description = "Name of VPC Network"
}
variable "mtu" {
  type        = number
  description = "IP MTU"
  default     = null
}
variable "regions" {
  description = "GCP Region Name"
  type = list(object({
    region                 = string
    main_cidr              = string
    proxy_only_cidr        = optional(string)
    subnet_name            = optional(string)
    proxy_only_subnet_name = optional(string)
    gke_pods_cidr          = optional(string)
    gke_services_cidr      = optional(string)
    attached_projects      = optional(list(string), [])
    shared_accounts        = optional(list(string), [])
    viewer_accounts        = optional(list(string), [])
    cloud_router_name      = optional(string)
    cloud_nat_name         = optional(string)
    vpn_gateway_name       = optional(string)
    cloud_router_bgp_asn   = optional(number)
  }))
  default = []
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
variable "enable_netapp" {
  description = "Enable PSA Connection to GCNV"
  type        = bool
  default     = false
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
variable "create_proxy_only_subnets" {
  type    = bool
  default = true
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
variable "internal_ips" {
  type    = list(string)
  default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10"]
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
