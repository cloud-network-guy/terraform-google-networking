variable "create" {
  type    = bool
  default = true
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "project" {
  type    = string
  default = null
}
variable "ncc_hub_name" {
  description = "The Name of the NCC Hub"
  type        = string
}

variable "ncc_hub_description" {
  description = "The description of the NCC Hub"
  type        = string
  default     = null
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "ncc_hub_labels" {
  description = "These labels will be added the NCC hub"
  type        = map(string)
  default     = {}
}

variable "ncc_hub_preset_topology" {
  description = "The topology implemented in the hub. Type must be one of `STAR`, `MESH` or `HYBRID_INSPECTION`."
  type        = string
  default     = null
}

variable "ncc_hub_policy_mode" {
  description = "The policy mode of the hub. Type must be one of `PRESET` or `CUSTOM`."
  type        = string
  default     = "PRESET"
}

variable "ncc_groups" {
  description = "Groups for Hubs using the star topolgy"
  type = map(object({
    name                 = optional(string)
    labels               = optional(map(string))
    description          = optional(string)
    auto_accept_projects = optional(list(string), [])
  }))
  default = {}
}

variable "export_psc" {
  description = "Whether Private Service Connect transitivity is enabled for the hub"
  type        = bool
  default     = false
}

variable "vpc_spokes" {
  description = "VPC network that is associated with the spoke. link_producer_vpc_network: Producer VPC network that is peered with vpc network"
  type = map(object({
    uri                   = string
    exclude_export_ranges = optional(set(string), [])
    include_export_ranges = optional(set(string), [])
    description           = optional(string)
    labels                = optional(map(string))
    group                 = optional(string)
    link_producer_vpc_network = optional(object({
      network_name          = string
      peering               = string
      include_export_ranges = optional(list(string))
      exclude_export_ranges = optional(list(string))
      description           = optional(string)
      labels                = optional(map(string))
      group                 = optional(string)
    }))
  }))
  default = {}
}

# variable "producer_vpc_network_spokes" {
#   type = map(object({
#     network_name          = string
#     peering               = string
#     include_export_ranges = optional(list(string))
#     exclude_export_ranges = optional(list(string))
#   }))
#   description = "Producer VPC network that is associated with the spoke."
#   default     = {}
# }

variable "hybrid_spokes" {
  description = "VLAN attachments and VPN Tunnels that are associated with the spoke. Type must be one of `interconnect` and `vpn`."
  type = map(object({
    location                   = string
    uris                       = optional(list(string), [])
    site_to_site_data_transfer = optional(bool, false)
    type                       = string
    description                = optional(string)
    labels                     = optional(map(string))
    include_import_ranges      = optional(list(string), [])
    group                      = optional(string)
    attachments                = optional(list(string), [])
    vpns                       = optional(list(string), [])
  }))
  default = {}
}

variable "router_appliance_spokes" {
  description = "Router appliance instances that are associated with the spoke."
  type = map(object({
    instances = set(object({
      virtual_machine = string
      ip_address      = string
    }))
    location                   = string
    site_to_site_data_transfer = optional(bool, false)
    description                = optional(string)
    labels                     = optional(map(string))
    include_import_ranges      = optional(list(string), [])
    group                      = optional(string)
  }))
  default = {}
}

variable "spoke_labels" {
  description = "These labels will be added to all NCC spokes"
  type        = map(string)
  default     = {}
}