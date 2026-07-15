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
variable "region" {
  description = "GCP Region Name"
  type        = string
  default     = null
}
variable "router" {
  description = "Name or URL of Cloud Router"
  type        = string
}
variable "create_interfaces" {
  description = "Automatically Create Router interfaces based on BGP peers"
  type        = bool
  default     = true
}
variable "interfaces" {
  description = "Explicit list of router interfaces (each must be mapped to vpn tunnel or interconnect attachment)"
  type = list(object({
    create = optional(bool, true)
    ip_range                = string
    name                    = optional(string)
    vpn_tunnel              = optional(string)
    interconnect_attachment = optional(string)
  }))
  validation {
    condition = alltrue([for interface in var.interfaces :
      anytrue([interface.vpn_tunnel != null ? true : false], [interface.interconnect_attachment != null ? true : false])
    ])
    error_message = "Each interface must set exactly one of vpn_tunnel or interconnect_attachment."
  }
  validation {
    condition     = length(var.interfaces) == length(distinct([for i in var.interfaces : i.name]))
    error_message = "Interface names must be unique."
  }
  default = []
}

variable "bgp_peers" {
  description = "List of BGP Peers"
  type = list(object({
    name                      = string
    interface_name            = string
    peer_asn                  = number
    peer_ip_address           = optional(string)
    peer_ipv6_nexthop_address = optional(string)
    ip_address                = optional(string)
    ipv6_nexthop_address      = optional(string)
    enable                    = optional(bool, true)
    enable_ipv6               = optional(bool, false)
    advertised_route_priority = optional(number)
    advertise_mode            = optional(string, "DEFAULT")
    advertised_groups         = optional(list(string), [])
    router_appliance_instance = optional(string)
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })), [])
    custom_learned_route_priority = optional(number)
    custom_learned_ip_ranges      = optional(list(string), [])
    bfd = optional(object({
      session_initialization_mode = optional(string, "DISABLED")
      min_transmit_interval       = optional(number)
      min_receive_interval        = optional(number)
      multiplier                  = optional(number)
    }))
    md5_authentication_key = optional(object({
      name = string
      key  = string
    }))
  }))
  default = []
  validation {
    condition = alltrue([
      for p in var.bgp_peers : contains(["DEFAULT", "CUSTOM"], p.advertise_mode)
    ])
    error_message = "advertise_mode must be either \"DEFAULT\" or \"CUSTOM\"."
  }
  validation {
    condition     = length(var.bgp_peers) == length(distinct([for p in var.bgp_peers : p.name]))
    error_message = "Peer names must be unique."
  }
}
