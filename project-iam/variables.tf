variable "project_id" {
  type    = string
  default = null
}
variable "project" {
  type    = string
  default = null
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
