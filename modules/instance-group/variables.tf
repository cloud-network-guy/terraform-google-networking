variable "project_id" {
  type = string
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
variable "create" {
  type    = bool
  default = true
}
variable "region" {
  type    = string
  default = null
}
variable "zone" {
  type    = string
  default = null
}
variable "instance" {
  type    = string
  default = null
}
variable "instances" {
  type    = list(string)
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
  type    = string
  default = "default"
}
variable "name_prefix" {
  type    = string
  default = null
}
variable "base_instance_name" {
  type    = string
  default = null
}
variable "target_size" {
  type    = number
  default = 2
}
variable "update_instance_redistribution_type" {
  type    = string
  default = "PROACTIVE"
}
variable "distribution_policy_target_shape" {
  type    = string
  default = "EVEN"
}
variable "update" {
  type = object({
    type                         = optional(string)
    minimal_action               = optional(string)
    most_disruptive_action       = optional(string)
    replacement_method           = optional(string)
    instance_redistribution_type = optional(string)
  })
  default = {}
}
variable "auto_healing_initial_delay" {
  type    = number
  default = 300
}
variable "health_check" {
  type    = string
  default = null
}
variable "health_checks" {
  type    = list(string)
  default = null
}
variable "autoscaling_mode" {
  type    = string
  default = "OFF"
}
variable "min_replicas" {
  type    = number
  default = 1
}
variable "max_replicas" {
  type    = number
  default = 10
}
variable "cpu_target" {
  type    = number
  default = 0.60
}
variable "cpu_predictive_method" {
  type    = string
  default = "NONE"
}
variable "cooldown_period" {
  type    = number
  default = 60
}
variable "instance_template" {
  type    = string
  default = null
}
variable "named_ports" {
  type = list(object({
    name = optional(string)
    port = optional(number)
  }))
  default = []
}
