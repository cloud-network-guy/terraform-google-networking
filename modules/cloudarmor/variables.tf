variable "create" {
  type    = bool
  default = null
}
variable "project_id" {
  type = string
}
variable "name" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "rules" {
  description = "List of Rules"
  type = list(object({
    action      = optional(string)
    priority    = number
    ip_ranges   = optional(list(string))
    expr        = optional(string)
    description = optional(string)
  }))
  default = []
}
variable "layer_7_ddos" {
  type    = bool
  default = false
}