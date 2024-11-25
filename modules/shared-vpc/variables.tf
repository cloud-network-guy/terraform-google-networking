variable "host_project_id" {
  description = "For Shared VPC, Project ID of the Host Network Project"
  type        = string
}
variable "network" {
  type    = string
  default = null
}
variable "region" {
  type    = string
  default = null
}
variable "subnetworks" {
  type = list(object({
    id                = optional(string)
    name              = optional(string)
    region            = optional(string)
    purpose           = optional(string)
    attached_projects = optional(list(string))
    shared_accounts   = optional(list(string))
    viewer_accounts   = optional(list(string))
  }))
}