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
variable "network" {
  type    = string
  default = "default"
}
variable "subnetwork" {
  type    = string
  default = "default"
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
variable "bucket_name" {
  type    = string
  default = null
}
variable "create_bucket" {
  type    = bool
  default = null
}
variable "bucket_location" {
  type    = string
  default = null
}
variable "locality_lb_policy" {
  type    = string
  default = null
}
variable "capacity_scaler" {
  type    = number
  default = null
}
variable "max_utilization" {
  type    = number
  default = null
}
variable "max_rate_per_instance" {
  type    = number
  default = null
}
variable "max_connections" {
  type    = number
  default = null
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
    application_title = optional(string)
    support_email     = optional(string)
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

