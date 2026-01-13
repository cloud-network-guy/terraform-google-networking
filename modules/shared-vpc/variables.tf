variable "host_project_id" {
  description = "For Shared VPC, Project ID of the Host Network Project"
  type        = string
}
variable "network" {
  description = "VPC Network Name, ID, or Self LInk"
  type        = string
  default     = null
}
variable "region" {
  description = "Default Region"
  type        = string
  default     = null
}
variable "give_project_viewer_access" {
  description = "Give all Service Accounts Compute Network Viewer permissions on the Host Network Project"
  type        = bool
  default     = false
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
  default = []
}