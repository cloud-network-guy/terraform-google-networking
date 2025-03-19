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
      subnetwork        = optional(string)
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
    balancing_mode               = optional(string)
    capacity_scaler              = optional(number)
    max_utilization              = optional(number)
    max_connections              = optional(number)
    max_connections_per_endpoint = optional(number)
    max_connections_per_instance = optional(number)
    max_rate                     = optional(number)
    max_rate_per_endpoint        = optional(number)
    max_rate_per_instance        = optional(number)
  }))
  default = {}
}
variable "frontends" {
  description = "List of Load Balancer Frontends or Forwarding Rules"
  type = map(object({
    create                     = optional(bool, true)
    project_id                 = optional(string)
    host_project_id            = optional(string)
    region                     = optional(string)
    name                       = optional(string)
    description                = optional(string)
    network                    = optional(string)
    subnetwork                 = optional(string)
    default_service            = optional(string)
    classic                    = optional(bool)
    existing_ssl_certs         = optional(list(string))
    existing_ssl_policy        = optional(string)
    backend_service            = optional(string)
    backend_service_id         = optional(string)
    backend_service_project_id = optional(string)
    backend_service_region     = optional(string)
    backend_service_name       = optional(string)
    target                     = optional(string)
    target_id                  = optional(string)
    target_project_id          = optional(string)
    enable_http                = optional(bool)
    enable_https               = optional(bool)
    redirect_http_to_https     = optional(bool)
    create_static_ip           = optional(bool)
    ip_address                 = optional(string)
    ipv4_address               = optional(string)
    ipv6_address               = optional(string)
    ip_address_name            = optional(string)
    ip_address_description     = optional(string)
    ipv4_address_name          = optional(string)
    ipv4_address_description   = optional(string)
    ipv6_address_name          = optional(string)
    ipv6_address_description   = optional(string)
    preserve_ip_addresses      = optional(bool)
    forwarding_rule_name       = optional(string)
    ipv4_forwarding_rule_name  = optional(string)
    ipv6_forwarding_rule_name  = optional(string)
    global_access              = optional(string)
    ssl_certs = optional(map(object({
      create          = optional(bool)
      active          = optional(bool)
      project_id      = optional(string)
      name            = optional(string)
      description     = optional(string)
      certificate     = optional(string)
      private_key     = optional(string)
      region          = optional(string)
      domains         = optional(list(string))
      ca_organization = optional(string)
      ca_valid_years  = optional(number)
    })))
    routing_rules = optional(map(object({
      create                    = optional(bool)
      project_id                = optional(string)
      name                      = optional(string)
      priority                  = optional(number)
      hosts                     = list(string)
      backend                   = optional(string)
      path                      = optional(string)
      request_headers_to_remove = optional(list(string))
      path_rules = optional(list(object({
        paths        = list(string)
        backend_name = optional(string)
        backend      = string
      })))
      redirect = optional(object({
        host        = optional(string)
        strip_query = optional(bool)
        code        = optional(string)
        https       = optional(bool)
      }))
    })))
    ssl_policy = optional(object({
      create          = optional(bool)
      project_id      = optional(string)
      name            = optional(string)
      description     = optional(string)
      min_tls_version = optional(string)
      tls_profile     = optional(string)
    }))
    psc = optional(object({
      create                   = optional(bool)
      project_id               = optional(string)
      host_project_id          = optional(string)
      name                     = optional(string)
      description              = optional(string)
      forwarding_rule_name     = optional(string)
      target_service_id        = optional(string)
      nat_subnetworks          = optional(list(string))
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
variable "security_policies" {
  description = "CloudArmor Security Policies"
  type = map(object({
    create       = optional(bool, true)
    project_id   = optional(string)
    name         = optional(string)
    description  = optional(string)
    layer_7_ddos = optional(bool)
    rules = list(object({
      action      = optional(string)
      priority    = number
      ip_ranges   = optional(list(string))
      expr        = optional(string)
      description = optional(string)
    }))
  }))
  default = {}
}
