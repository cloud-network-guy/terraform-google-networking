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
variable "create_static_ip" {
  description = "Create and use Static IP address"
  type        = bool
  default     = true
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
  type = string
}
variable "subnetwork" {
  type = string
}
variable "target_google_api" {
  type    = string
  default = null
}
variable "global_access" {
  type    = bool
  default = false
}
variable "labels" {
  description = "Labels applied to the endpoint and the reserved address."
  type        = map(string)
  default     = {}
}
