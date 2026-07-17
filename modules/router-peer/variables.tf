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
}
variable "router" {
  description = "Name or URL of Cloud Router"
  type        = string
}
variable "create_interface" {
  description = "Automatically Create Router interfaces based on BGP peers"
  type        = bool
  default     = true
}
variable "interface_name" {
  description = "Explicit name of the Router Interface"
  type        = string
  default     = null
}
variable "interface_index" {
  description = "Explicit index of the Router Interface"
  type        = string
  default     = null
}
variable "interface_ip_range" {
  description = "IP Range to use on GCP Cloud Router interface"
  type        = string
}
variable "vpn_tunnel" {
  description = "Name of the VPN tunnel that uses the interface"
  type        = string
  default     = null
}
variable "interconnect_attachment" {
  description = "Name of the Interconnect attachment that uses the interface"
  type        = string
  default     = null
}
variable "name" {
  description = "Router Peer Name"
  type        = string
  default     = null
}
variable "cloud_router_ip" {
  type = string
}
variable "peer_bgp_name" {
  type    = string
  default = null
}
variable "peer_bgp_asn" {
  type    = number
  default = null
}
variable "peer_ip_address" {
  type    = string
  default = null
}
variable "enable" {
  type    = bool
  default = true
}
variable "enable_ipv4" {
  type    = bool
  default = true
}
variable "enable_ipv6" {
  type    = bool
  default = false
}
variable "advertised_route_priority" {
  type    = number
  default = null
}
variable "advertise_mode" {
  type    = string
  default = null
}
variable "advertised_groups" {
  type    = list(string)
  default = []
}
variable "router_appliance_instance" {
  type    = string
  default = null
}
variable "advertised_ip_ranges" {
  type = list(object({
    range       = string
    description = optional(string)
  }))
  default = []
}
variable "custom_learned_route_priority" {
  type    = number
  default = null
}
variable "zero_custom_learned_route_priority" {
  type    = bool
  default = false
}
variable "custom_learned_ip_ranges" {
  type    = list(string)
  default = []
}
variable "bfd" {
  type = object({
    session_initialization_mode = optional(string, "DISABLED")
    min_transmit_interval       = optional(number)
    min_receive_interval        = optional(number)
    multiplier                  = optional(number)
  })
  default = null
}
variable "md5_authentication_key" {
  type = object({
    name = string
    key  = string
  })
  default = null
}
