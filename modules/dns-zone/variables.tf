variable "project_id" {
  type = string
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
variable "name" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "dns_name" {
  type = string
}
variable "target_name_servers" {
  type = list(object({
    ipv4_address    = string
    forwarding_path = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([for ns in coalesce(var.target_name_servers, []) :
      contains(["default", "private"], trimspace(lower(ns.forwarding_path)))
    ])
    error_message = "Name Server forwarding path must be 'default' or 'private'."
  }
}
variable "visibility" {
  type    = string
  default = null
}
variable "networks" {
  type    = list(string)
  default = []
}
variable "peer_project_id" {
  type    = string
  default = null
}
variable "peer_project" {
  type    = string
  default = null
}
variable "peer_network_id" {
  type    = string
  default = null
}
variable "peer_network" {
  type    = string
  default = null
}
variable "records" {
  type = list(object({
    create  = optional(bool, true)
    name    = string
    type    = optional(string)
    ttl     = optional(number)
    rrdatas = list(string)
  }))
  default = []
}
variable "force_destroy" {
  type    = bool
  default = false
}
variable "logging" {
  type    = bool
  default = false
}