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
  description = "Name for the Published Service"
  type        = string
  default     = null
}
variable "description" {
  description = "Description for the Published Service"
  type        = string
  default     = null
}
variable "region" {
  description = "GCP region name"
  type        = string
  default     = null
}
variable "network" {
  type    = string
  default = "default"
}
variable "nat_subnet" {
  type    = string
  default = null
}
variable "nat_subnets" {
  type    = list(string)
  default = []
}
variable "target_service" {
  description = "Forwarding Rule Service ID to publish"
  type        = string
  default     = null
}
variable "forwarding_rule_name" {
  description = "Forwarding Rule Name to publish (must be in same project)"
  type        = string
  default     = null
}
variable "enable_proxy_protocol" {
  description = "enable the proxy protocol"
  type        = bool
  default     = false
}
variable "reconcile_connections" {
  type    = bool
  default = true
}
variable "auto_accept_all_projects" {
  description = "Set whether to auto-accept connections from any project"
  type        = bool
  default     = false
}
variable "consumer_accept_list" {
  description = "List of Project IDs to accept connections from"
  type = list(object({
    project          = string
    connection_limit = optional(number, 10)
  }))
  default = []
}
variable "consumer_reject_list" {
  type = list(object({
    project = string
  }))
  default = []
}
variable "domain_names" {
  type    = list(string)
  default = []
}
