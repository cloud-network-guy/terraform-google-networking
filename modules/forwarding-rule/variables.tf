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
  default = false
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