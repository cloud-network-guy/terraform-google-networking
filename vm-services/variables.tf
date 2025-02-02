variable "create" {
  type    = bool
  default = true
}
variable "project_id" {
  description = "GCP Project ID of GCP"
  type        = string
}
variable "name_prefix" {
  description = "Name prefix for the instances"
  type        = string
  default = "instance"
}
variable "machine_type" {
  description = "Machine Type"
  type        = string
  default     = "e2-small"
}
variable "disk_type" {
  description = "Disk Type"
  type        = string
  default     = "pd-standard"
}
variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}
variable "os_project" {
  description = "GCP OS Project"
  type        = string
  default     = null
}
variable "os" {
  description = "GCP OS Name"
  type        = string
  default     = "debian-12"
}
variable "disk_image" {
  description = "Image to use"
  type        = string
  default     = null
}
variable "startup_script" {
  description = "Startup Script"
  type        = string
  default     = null
}
variable "service_account_email" {
  description = "Service Account e-mail address"
  type        = string
  default     = null
}
variable "service_account_scopes" {
  description = "List of Service Account Scopes"
  type        = list(string)
  default     = ["compute-rw", "storage-rw", "logging-write", "monitoring"]
}
variable "network_tags" {
  description = "List of Network Tags"
  type        = list(string)
  default     = null
}
variable "host_project_id" {
  description = "If using Shared VPC, the Project ID that hosts the VPC network"
  type        = string
  default     = null
}
variable "network" {
  description = "Name of the VPC Network"
  type        = string
  default     = null
}
variable "labels" {
  type    = map(any)
  default = null
}
variable "deployments" {
  description = "Regions to deploy instances to"
  type = map(object({
    create                 = optional(bool)
    name                   = optional(string)
    region                 = optional(string)
    zone                   = optional(string)
    machine_type           = optional(string)
    disk_image             = optional(string)
    disk_type              = optional(string)
    disk_size              = optional(number)
    os_project             = optional(string)
    os                     = optional(string)
    network                = optional(string)
    subnetwork             = optional(string)
    startup_script         = optional(string)
    network_tags           = optional(list(string))
    service_account_email  = optional(string)
    service_account_scopes = optional(list(string))
  }))
  default = {}
}
