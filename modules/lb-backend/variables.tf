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
  default = "INTERNAL"
}
variable "protocol" {
  type    = string
  default = null
}
variable "health_checks" {
  type    = list(string)
  default = null
}
variable "health_check" {
  type    = string
  default = null
}
variable "groups" {
  type    = list(string)
  default = null
}
variable "group" {
  type    = string
  default = null
}
variable "session_affinity" {
  type    = string
  default = "NONE"
}
variable "classic" {
  type    = bool
  default = false
}
variable "port" {
  type    = number
  default = null
}
variable "port_name" {
  type    = string
  default = null
}
variable "logging" {
  type    = bool
  default = false
}
variable "logging_sample_rate" {
  type    = number
  default = 1
}
variable "timeout" {
  type    = number
  default = 30
}
variable "security_policy" {
  type    = string
  default = null
}
variable "locality_lb_policy" {
  type    = string
  default = null
}
variable "balancing_mode" {
  type    = string
  default = null
}
variable "ip_address_selection_policy" {
  type    = string
  default = null
}
variable "capacity_scaler" {
  type    = number
  default = null
}
variable "max_utilization" {
  type    = number
  default = 0
}
variable "max_rate" {
  type    = number
  default = 0
}
variable "max_rate_per_instance" {
  type    = number
  default = 0
}
variable "max_rate_per_endpoint" {
  type    = number
  default = 0
}
variable "max_connections" {
  type    = number
  default = 0
}
variable "max_connections_per_endpoint" {
  type    = number
  default = 0
}
variable "max_connections_per_instance" {
  type    = number
  default = 0
}
variable "connection_draining_timeout_sec" {
  type    = number
  default = 300
}
variable "bucket" {
  type = object({
    name     = optional(string)
    location = optional(string)
  })
  default = null
}
variable "iap" {
  type = object({
    create            = optional(bool)
    application_title = optional(string)
    support_email     = optional(string)
    display_name      = optional(string)
    members           = optional(list(string))
  })
  default = null
}
variable "cdn" {
  type = object({
    cache_mode = optional(string)
  })
  default = null
}
variable "custom_request_headers" {
  type    = list(string)
  default = null
}
