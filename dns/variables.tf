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
variable "dns_zones" {
  description = "List of DNS zones"
  type = map(object({
    create          = optional(bool, true)
    project_id      = optional(string)
    host_project_id = optional(string)
    host_project    = optional(string)
    key             = optional(string)
    dns_name        = string
    name            = optional(string)
    description     = optional(string)
    visibility      = optional(string)
    networks        = optional(list(string))
    peer_project    = optional(string)
    peer_network    = optional(string)
    logging         = optional(bool)
    force_destroy   = optional(bool)
    target_name_servers = optional(list(object({
      ipv4_address    = string
      forwarding_path = optional(string, "default")
    })))
    records = optional(list(object({
      create  = optional(bool, true)
      key     = optional(string)
      name    = string
      type    = optional(string)
      ttl     = optional(number)
      rrdatas = list(string)
    })))
  }))
  default = {}
}
variable "dns_policies" {
  description = "List of DNS Policies"
  type = map(object({
    create                    = optional(bool, true)
    project_id                = optional(string)
    key                       = optional(string)
    name                      = optional(string)
    description               = optional(string)
    logging                   = optional(bool)
    enable_inbound_forwarding = optional(bool)
    target_name_servers = optional(list(object({
      ipv4_address    = optional(string)
      forwarding_path = optional(string)
    })))
    networks = optional(list(string))
  }))
  default = {}
}
