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
variable "network" {
  type    = string
  default = null
}
variable "subnetwork" {
  type    = string
  default = null
}
variable "type" {
  type    = string
  default = null
}
variable "network_tier" {
  type    = string
  default = null
}
variable "protocol" {
  type    = string
  default = null
}
variable "all_ports" {
  type    = bool
  default = null
}
variable "backend_service" {
  type    = string
  default = null
}
variable "target" {
  type    = string
  default = null
}
variable "global_access" {
  type    = bool
  default = false
}
variable "classic" {
  type    = bool
  default = false
}
variable "labels" {
  type    = map(string)
  default = null
}
variable "port" {
  type    = number
  default = null
}
variable "ports" {
  type    = list(number)
  default = null
}
variable "port_range" {
  type    = string
  default = null
}
variable "psc" {
  description = "Parameters to Publish this Frontend via PSC"
  type = object({
    create                   = optional(bool)
    host_project             = optional(string)
    name                     = optional(string)
    description              = optional(string)
    nat_subnets              = optional(list(string))
    enable_proxy_protocol    = optional(bool)
    auto_accept_all_projects = optional(bool)
    accept_projects = optional(list(object({
      project          = string
      connection_limit = optional(number)
    })))
    domain_names          = optional(list(string))
    consumer_reject_lists = optional(list(string))
    reconcile_connections = optional(bool)
  })
  default = null
}
