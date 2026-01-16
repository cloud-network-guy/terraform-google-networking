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
variable "org_id" {
  type    = number
  default = null
}
variable "org" {
  type    = number
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
variable "networks" {
  type    = list(string)
  default = []
}
variable "region" {
  type    = string
  default = null
}
variable "address_groups" {
  type = map(object({
    create      = optional(bool, true)
    project_id  = optional(string)
    org_id      = optional(number)
    name        = optional(string)
    description = optional(string)
    parent      = optional(string)
    region      = optional(string)
    type        = optional(string)
    capacity    = optional(number)
    items       = list(string)
    labels      = optional(map(string))
  }))
  default = {}
}
variable "rules" {
  type = list(object({
    create                     = optional(bool, true)
    priority                   = optional(number)
    description                = optional(string)
    direction                  = optional(string)
    ranges                     = optional(list(string))
    range                      = optional(string)
    source_ranges              = optional(list(string))
    destination_ranges         = optional(list(string))
    address_groups             = optional(list(string))
    range_types                = optional(list(string))
    range_type                 = optional(string)
    protocol                   = optional(string)
    protocols                  = optional(list(string))
    port                       = optional(number)
    ports                      = optional(list(number))
    source_address_groups      = optional(list(string))
    destination_address_groups = optional(list(string))
    target_tags                = optional(list(string))
    target_service_accounts    = optional(list(string))
    action                     = optional(string)
    logging                    = optional(bool)
    disabled                   = optional(bool)
  }))
  default = []
}
