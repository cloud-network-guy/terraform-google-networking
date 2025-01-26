variable "create" {
  type    = bool
  default = true
}
variable "name" {
  description = "Network Name"
  type        = string
  default     = null
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "regions" {
  type    = list(string)
  default = ["us-central1"]
}
variable "network_name" {
  type        = string
  description = "Name of VPC Network"
  default     = null
}
variable "mtu" {
  type        = number
  description = "IP MTU"
  default     = null
}
variable "cloud_router_bgp_asn" {
  type    = string
  default = 64512
}
variable "psc_endpoints" {
  type = list(object({
    project_id             = optional(string)
    name                   = optional(string)
    description            = optional(string)
    subnet                 = optional(string)
    ip_address             = optional(string)
    ip_address_name        = optional(string)
    ip_address_description = optional(string)
    target                 = string
  }))
  default = []
}
