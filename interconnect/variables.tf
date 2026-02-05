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
variable "host_project_id" {
  type        = string
  description = "If using Shared VPC, the Project ID that hosts the VPC network"
  default     = null
}
variable "host_project" {
  type        = string
  description = "If using Shared VPC, the Project ID that hosts the VPC network"
  default     = null
}
variable "region" {
  description = "Name of the GCP Region"
  type        = string
}
variable "router" {
  description = "Name of the Cloud Router"
  type        = string
}
variable "type" {
  type    = string
  default = "PARTNER"
}
variable "mtu" {
  description = "Default MTU for all attachments"
  type        = number
  default     = 1440
}
variable "peer_asn" {
  description = "BGP AS Number of On-Prem Router"
  type        = number
  default     = 16550
}
variable "advertised_route_priority" {
  type    = number
  default = 100
}
variable "advertised_ip_ranges" {
  type    = list(string)
  default = []
}
variable "encryption" {
  type    = string
  default = "NONE"
}
variable "bfd" {
  type        = bool
  description = "Enable BFD"
  default     = false
}
variable "enable_ipv4" {
  type    = bool
  default = true
}
variable "enable_ipv6" {
  type    = bool
  default = false
}
variable "attachments" {
  type = list(object({
    create                    = optional(bool, true)
    name                      = optional(string)
    description               = optional(string)
    mtu                       = optional(number)
    interface_index           = optional(number)
    interface_name            = optional(string)
    ip_range                  = optional(string) # IP and prefix to use on GCP Cloud Router side
    peer_ip_address           = optional(string) # IP address of BGP peer
    peer_name                 = optional(string) # Name of BGP Peer
    peer_asn                  = optional(number)
    enable_ipv4               = optional(bool)
    enable_ipv6               = optional(bool)
    advertised_route_priority = optional(number)
    advertised_groups         = optional(list(string))
    advertised_ip_ranges      = optional(list(string))
    ipsec_internal_addresses  = optional(list(string))
    bfd                       = optional(bool)
  }))
  default = []
}

