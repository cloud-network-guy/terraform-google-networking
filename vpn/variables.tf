variable "create" {
  type    = bool
  default = true
}
variable "project_id" {
  type        = string
  description = "Default GCP Project ID (can be overridden at resource level)"
  default     = null
}
variable "project" {
  type        = string
  description = "Default GCP Project ID (can be overridden at resource level)"
  default     = null
}
variable "region" {
  description = "Name of the GCP Region"
  type        = string
}
variable "router" {
  description = "Name of the Cloud Router"
  type        = string
  default     = null
}
variable "network" {
  description = "Name of the VPC Network (can be used to find router)"
  type        = string
  default     = null
}
variable "cloud_vpn_gateway" {
  description = "Name of the Cloud VPN Gateway"
  type        = string
}

variable "peer_vpn_gateways" {
  description = "External / Peer VPN Gateways "
  type = map(object({
    name        = optional(string)
    description = optional(string)
    bgp_asn     = optional(number, 65000)
    create      = optional(bool, true)
    interfaces = list(object({
      ip_address  = string
      description = optional(string)
      bgp_asn     = optional(number)
    }))
  }))
  default = {}
}
variable "advertised_route_priority" {
  description = "Default Priority (BGP MED) to advertise"
  type        = number
  default     = null
}
variable "peer_bgp_asn" {
  description = "Default BGP ASN number for all Peer (External) VPN Gateways"
  type        = number
  default     = 65000
}
variable "advertised_ip_ranges" {
  type    = list(string)
  default = []
}
variable "bfd" {
  description = "Enable BFD for all BGP Sessions"
  type        = bool
  default     = false
}
variable "vpns" {
  description = "HA VPNs"
  type = map(object({
    create                       = optional(bool, true)
    project                      = optional(string)
    project_id                   = optional(string)
    name                         = optional(string)
    description                  = optional(string)
    ike_version                  = optional(number)
    region                       = optional(string)
    router                       = optional(string)
    cloud_vpn_gateway            = optional(string)
    peer_vpn_gateway             = optional(string)
    peer_gcp_vpn_gateway_project = optional(string)
    peer_gcp_vpn_gateway         = optional(string)
    peer_bgp_asn                 = optional(number)
    advertised_priority          = optional(number)
    advertised_groups            = optional(list(string))
    advertised_prefixes          = optional(list(string))
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })), [])
    custom_learned_ip_ranges = optional(list(object({
      range = string
    })), [])
    enable_bfd     = optional(bool)
    bfd_multiplier = optional(number)
    tunnels = list(object({
      create               = optional(bool)
      name                 = optional(string)
      description          = optional(string)
      interface_name       = optional(string)
      interface_index      = optional(number)
      shared_secret        = optional(string)
      ip_range             = optional(string)
      cloud_router_ip      = optional(string)
      peer_bgp_name        = optional(string)
      peer_bgp_ip          = optional(string)
      peer_bgp_asn         = optional(number)
      peer_interface_index = optional(number)
      advertised_priority  = optional(number)
      advertised_groups    = optional(list(string))
      advertised_ip_ranges = optional(list(object({
        range       = string
        description = optional(string)
      })), [])
      custom_learned_ip_ranges = optional(list(object({
        range = string
      })), [])
      enable      = optional(bool)
      enable_bfd  = optional(bool)
      enable_ipv6 = optional(bool)
    }))
  }))
  default = {}
}

