variable "create" {
  type    = bool
  default = null
}
variable "project_id" {
  type = string
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
variable "region" {
  type    = string
  default = null
}
variable "zone" {
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
variable "type" {
  type    = string
  default = null
}
variable "protocol" {
  type    = string
  default = null
}
variable "ip_address" {
  type    = string
  default = null
}
variable "fqdn" {
  type    = string
  default = null
}
variable "default_port" {
  type    = number
  default = null
}
variable "port" {
  type    = number
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
variable "cloud_run_service" {
  type    = string
  default = null
}
variable "psc_target" {
  type    = string
  default = null
}
variable "endpoints" {
  type = list(object({
    ip_address = optional(string)
    port       = optional(number)
    fqdn       = optional(string)
    instance   = optional(string)
  }))
  default = []
}
