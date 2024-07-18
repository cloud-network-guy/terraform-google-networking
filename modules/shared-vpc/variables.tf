variable "credentials_file" {
  description = "GCP service account JSON key"
  type        = string
  sensitive   = true
  default     = null
}
variable "host_project_id" {
  description = "For Shared VPC, Project ID of the Host Network Project"
  type        = string
}
variable "projects" {
  description = "List of specific Project IDs to include"
  type        = list(string)
  default     = null
}
variable "org_id" {
  description = "Organization ID containing list of Projects to examine"
  type        = string
  default     = null
}
variable "folder_id" {
  description = "Folder ID containing list of Projects to examine"
  type        = string
  default     = null
}
variable "regional_labels" {
  description = "List of Fields to search for region"
  type        = list(string)
  default     = []
}
variable "network" {
  description = "Name of a specific VPC Network"
  type        = string
  default     = null
}
variable "name_prefix" {
  description = "Name Prefix for Regional Networks"
  type        = string
  default     = null
}
variable "regions" {
  description = "List of Regions to limit Scope to"
  type        = list(string)
  default     = []
}