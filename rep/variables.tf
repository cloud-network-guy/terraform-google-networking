variable "project_id" {
  type    = string
  default = null
}
variable "project" {
  type    = string
  default = null
}
variable "host_project_id" {
  type    = string
  default = null
}
variable "host_project" {
  type    = string
  default = null
}
variable "create" {
  type    = bool
  default = true
}
variable "region" {
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
variable "create_static_ip" {
  description = "Create and use Static IP address"
  type        = bool
  default     = true
}
variable "address" {
  type    = string
  default = null
}
variable "address_name" {
  type    = string
  default = null
}
variable "address_description" {
  type    = string
  default = null
}
variable "set_address_labels" {
  type    = bool
  default = false
}
variable "network" {
  type = string
}
variable "subnetwork" {
  type = string
}
variable "target_google_api" {
  type    = string
  default = null
}
variable "global_access" {
  type    = bool
  default = false
}
variable "labels" {
  description = "Labels applied to the endpoint and the reserved address."
  type        = map(string)
  default     = {}
}
variable "dns_zones" {
  description = "List of DNS zones"
  type = list(object({
    create          = optional(bool, true)
    project         = optional(string)
    dns_name        = string
    name            = optional(string)
    description     = optional(string)
    ttl             = optional(number, 60)
    create_wildcard = optional(bool, false)
    wildcard_tll    = optional(number, 300)
  }))
  default = []
}
