variable "project_id" {
  type    = string
  default = null
}
variable "project" {
  type    = string
  default = null
}
variable "org_domain" {
  type        = string
  description = "GCP Organizational Domain"
  default     = null
}
variable "service_accounts" {
  description = "Service Accounts"
  type = map(object({
    create       = optional(bool, true)
    account_id   = optional(string)
    name         = optional(string)
    display_name = optional(string)
    description  = optional(string)
    roles        = optional(list(string), [])
  }))
  default = {}
}
variable "group_roles" {
  description = "Map of roles based on groups"
  type        = map(list(string))
  default     = {}
}
variable "user_roles" {
  description = "Map of roles for individual users"
  type        = map(list(string))
  default     = {}
}
