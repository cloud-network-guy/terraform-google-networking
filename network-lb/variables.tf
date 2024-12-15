variable "project_id" {
  type = string
}
variable "host_project_id" {
  type    = string
  default = null
}
variable "name_prefix" {
  type    = string
  default = null
}
variable "region" {
  type    = string
  default = null
}
variable "type" {
  type    = string
  default = null
}
variable "network" {
  type    = string
  default = null
}
variable "subnetwork" {
  type    = string
  default = null
}
variable "classic" {
  type    = bool
  default = false
}
variable "global_access" {
  type    = bool
  default = false
}
variable "redirect_http_to_https" {
  type    = bool
  default = false
}
variable "logging" {
  type    = bool
  default = null
}
variable "backend_timeout" {
  type    = number
  default = null
}
variable "backend_protocol" {
  type    = string
  default = null
}
variable "session_affinity" {
  type    = string
  default = null
}
variable "locality_lb_policy" {
  type    = string
  default = null
}
variable "security_policy" {
  type    = string
  default = null
}
variable "existing_ssl_policy" {
  type    = string
  default = null
}
variable "existing_security_policy" {
  type    = string
  default = null
}
variable "preserve_ip_addresses" {
  type    = bool
  default = null
}
variable "create_service_label" {
  type    = bool
  default = null
}

variable "health_checks" {
  type = map(object({
    create              = optional(bool, true)
    project_id          = optional(string)
    name                = optional(string)
    description         = optional(string)
    region              = optional(string)
    port                = optional(number)
    protocol            = optional(string)
    interval            = optional(number)
    timeout             = optional(number)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    request_path        = optional(string)
    response            = optional(string)
    host                = optional(string)
    legacy              = optional(bool)
    logging             = optional(bool)
    proxy_header        = optional(string)
  }))
  default = {}
}
variable "backends" {
  type = map(object({
    create                   = optional(bool, true)
    project_id               = optional(string)
    host_project_id          = optional(string)
    name                     = optional(string)
    description              = optional(string)
    region                   = optional(string)
    port                     = optional(number)
    protocol                 = optional(string)
    timeout                  = optional(number)
    logging                  = optional(bool)
    enable_cdn               = optional(bool)
    enable_iap               = optional(bool)
    health_check             = optional(string)
    health_checks            = optional(list(string))
    existing_health_check    = optional(string)
    security_policy          = optional(string)
    existing_security_policy = optional(string)
    session_affinity         = optional(string)
    locality_lb_policy       = optional(string)
    classic                  = optional(bool)
    network                  = optional(string)
    subnetwork               = optional(string)
    groups                   = optional(list(string))
    ip_address               = optional(string)
    fqdn                     = optional(string)
    psc_target               = optional(string)
    cloud_run_service        = optional(string)
    instance_groups = optional(list(object({
      id         = optional(string)
      project_id = optional(string)
      zone       = optional(string)
      name       = optional(string)
    })))
    negs = optional(list(object({
      name              = optional(string)
      network           = optional(string)
      subnet            = optional(string)
      region            = optional(string)
      zone              = optional(string)
      instance          = optional(string)
      fqdn              = optional(string)
      ip_address        = optional(string)
      port              = optional(number)
      default_port      = optional(number)
      psc_target        = optional(string)
      cloud_run_service = optional(string)
      endpoints = optional(list(object({
        instance   = optional(string)
        fqdn       = optional(string)
        ip_address = optional(string)
        port       = optional(number)
      })))
    })))
    cdn = optional(object({
      cache_mode = optional(string)
    }))
  }))
  default = {}
}
variable "frontends" {
  type = map(object({
    create                = optional(bool, true)
    project_id            = optional(string)
    host_project_id       = optional(string)
    region                = optional(string)
    name                  = optional(string)
    description           = optional(string)
    network               = optional(string)
    subnetwork            = optional(string)
    ports                 = optional(list(number))
    backend               = optional(string)
    create_static_ip      = optional(bool)
    ip_address            = optional(string)
    ipv4_address          = optional(string)
    ipv6_address          = optional(string)
    ip_address_name       = optional(string)
    ipv4_address_name     = optional(string)
    ipv6_address_name     = optional(string)
    preserve_ip_addresses = optional(bool)
    global_access         = optional(string)
    create_service_label  = optional(bool)
    service_label         = optional(string)
    psc = optional(object({
      create                   = optional(bool)
      project_id               = optional(string)
      host_project_id          = optional(string)
      name                     = optional(string)
      description              = optional(string)
      forwarding_rule_name     = optional(string)
      target_service_id        = optional(string)
      nat_subnets              = optional(list(string))
      enable_proxy_protocol    = optional(bool)
      auto_accept_all_projects = optional(bool)
      accept_project_ids = optional(list(object({
        project_id       = string
        connection_limit = optional(number)
      })))
      domain_names          = optional(list(string))
      consumer_reject_lists = optional(list(string))
      reconcile_connections = optional(bool)
    }))
  }))
  default = {}
}
