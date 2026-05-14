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
variable "set_null_subnetwork" {
  description = "Set subnetwork attribute to null for forwarding rule"
  type        = bool
  default     = null
}
variable "target" {
  description = "PSC Target"
  type        = string
  default     = null
}
variable "target_id" {
  description = "PSC Target ID"
  type        = string
  default     = null
}
variable "target_project" {
  description = "PSC Target Project ID"
  type        = string
  default     = null
}
variable "target_region" {
  description = "PSC Target Service Region"
  type        = string
  default     = null
}
variable "target_name" {
  description = "PSC Target Service Name"
  type        = string
  default     = null
}
variable "global_access" {
  type    = bool
  default = false
}
