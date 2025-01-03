variable "project_id" {
  type = string
}
variable "project" {
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
variable "logging" {
  type    = bool
  default = false
}
variable "enable_inbound_forwarding" {
  type    = bool
  default = false
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
variable "networks" {
  type    = list(string)
  default = null
}
variable "network" {
  type = string
  default = null
}