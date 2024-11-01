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
variable "labels" {
  type    = map(string)
  default = {}
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
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}
variable "name_prefix" {
  type    = string
  default = null
}
variable "base_instance_name" {
  type    = string
  default = null
}
variable "machine_type" {
  type    = string
  default = "e2-micro"
}
variable "os_project" {
  type    = string
  default = "debian-cloud"
}
variable "os" {
  type    = string
  default = "debian-12"
}
variable "image" {
  type    = string
  default = null
}
variable "startup_script" {
  type    = string
  default = null
}
variable "can_ip_forward" {
  type    = bool
  default = false
}
variable "disk" {
  type = object({
    source_image = optional(string)
    boot         = optional(bool)
    auto_delete  = optional(bool)
    type         = optional(string)
    size_gb      = optional(number)
    interface    = optional(string)
    mode         = optional(string)
  })
  default = {}
}
