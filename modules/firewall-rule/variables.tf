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
variable "name" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "network" {
  type = string
}
variable "priority" {
  type    = number
  default = 1000
}
variable "logging" {
  type    = bool
  default = false
}
variable "direction" {
  type    = string
  default = "INGRESS"
}
variable "disabled" {
  type    = bool
  default = false
}