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
variable "region" {
  type    = string
  default = null
}
variable "zone" {
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
variable "networks" {
  type    = list(string)
  default = []
}
variable "labels" {
  type    = map(string)
  default = null
}
variable "tags" {
  type    = list(string)
  default = null
}
variable "network_tags" {
  type    = list(string)
  default = null
}
variable "service_account" {
  type    = string
  default = null
}
variable "service_account_email" {
  type    = string
  default = null
}
variable "service_account_scopes" {
  type    = list(string)
  default = null
}
variable "machine_type" {
  type    = string
  default = "e2-micro"
}
variable "os_project" {
  type    = string
  default = null
}
variable "os" {
  type    = string
  default = null
}
variable "image" {
  type    = string
  default = null
}
variable "metadata" {
  type = map(string)
  default = {
    enable-osconfig = "true"
  }
}
variable "startup_script" {
  type    = string
  default = null
}
variable "can_ip_forward" {
  type    = bool
  default = false
}
variable "delete_protection" {
  type    = bool
  default = null
}
variable "allow_stopping_for_update" {
  type    = bool
  default = null
}
variable "disk" {
  type = object({
    image = optional(string)
    type  = optional(string)
    size  = optional(number)
  })
  default = {}
}
