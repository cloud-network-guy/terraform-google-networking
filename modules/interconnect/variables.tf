variable "project_id" {
  description = "Project ID of GCP Project"
  type        = string
}
variable "name_prefix" {
  description = "Name Prefix for the Interconnect"
  type        = string
  default     = null
}
variable "region" {
  description = "Name of the GCP Region"
  type        = string
}
variable "cloud_router" {
  description = "Name of the Cloud Router"
  type        = string
}
variable "type" {
  type    = string
  default = "PARTNER"
}
variable "mtu" {
  type    = number
  default = 1440
}
variable "peer_bgp_asn" {
  type    = number
  default = 16550
}
variable "advertised_priority" {
  type    = number
  default = 100
}
variable "advertised_ip_ranges" {
  type    = list(string)
  default = []
}
variable "encryption" {
  type    = string
  default = null
}
variable "attachments" {
  type = list(object({
    name                     = optional(string)
    description              = optional(string)
    mtu                      = optional(number)
    interface_index          = optional(number)
    interface_name           = optional(string)
    cloud_router_ip          = optional(string)
    peer_bgp_ip              = optional(string)
    peer_bgp_asn             = optional(string)
    peer_bgp_name            = optional(string)
    advertised_priority      = optional(number)
    advertised_groups        = optional(list(string))
    advertised_ip_ranges     = optional(list(string))
    ipsec_internal_addresses = optional(list(string))
  }))
  default = []
}
