variable "create" {
  description = "Flag on wether to actually create this resource"
  type        = bool
  default     = true
}
variable "project_id" {
  description = "Default GCP Project ID (can be overridden at resource level)"
  type        = string
  default     = null
}
variable "host_project_id" {
  description = "Default Shared VPC Host Project (can be overridden at resource level)"
  type        = string
  default     = null
}
variable "name" {
  description = "Name of resource to create"
  type        = string
  default     = null
}
variable "zone" {
  description = "GCP Zone Name"
  type        = string
  default     = "us-central1-a"
}
variable "network" {
  description = "Name or URL of VPC Network to use"
  type        = string
  default     = "default"
}
variable "instances" {
  description = "Names of instances to have in this group"
  type        = list(string)
  default     = []
}
variable "named_ports" {
  description = "List of Named Ports"
  type = list(object({
    name = string
    port = number
  }))
  default = []
}
