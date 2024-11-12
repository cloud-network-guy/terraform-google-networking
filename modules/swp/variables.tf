variable "create" {
  type    = bool
  default = true
}
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
variable "address" {
  type    = string
  default = null
}
variable "addresses" {
  type    = list(string)
  default = null
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
variable "network" {
  type    = string
  default = null
}
variable "subnetwork" {
  type    = string
  default = null
}
variable "rules" {
  description = "List of manually controlled rules for this SWP Policy"
  type = list(object({
    create              = optional(bool, true)
    priority            = optional(number)
    name                = optional(string)
    description         = optional(string)
    session_matcher     = optional(string)
    application_matcher = optional(string)
    basic_profile       = optional(string)
    enabled             = optional(bool)
  }))
  default = []
}
variable "url_list" {
  description = "List of domains allow"
  type    = list(string)
  default = []
}