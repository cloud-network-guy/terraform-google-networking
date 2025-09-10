# Healthchecks
locals {
  project = lower(trimspace(coalesce(var.project_id, var.project)))
  type    = lower(trimspace(coalesce(var.type, "external")))
  health_checks = { for k, v in var.health_checks : k =>
    merge(v, {
      project     = coalesce(v.project_id, local.project)
      name        = coalesce(v.name, var.name_prefix != null ? "${var.name_prefix}-${k}" : k)
      description = trimspace(coalesce(v.description, "Managed by Terraform"))
      logging     = try(coalesce(v.logging, var.logging), null)
    })
  }
}
module "healthchecks" {
  source              = "../modules/healthcheck"
  for_each            = { for k, v in local.health_checks : k => v }
  project             = each.value.project
  name                = each.value.name
  description         = each.value.description
  region              = each.value.region
  host                = each.value.host
  port                = each.value.port
  protocol            = each.value.protocol
  request_path        = each.value.request_path
  response            = each.value.response
  interval            = each.value.interval
  timeout             = each.value.timeout
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  logging             = each.value.logging
  legacy              = each.value.legacy
}

# Start walking through backends
locals {
  _backends = { for backend_key, backend in var.backends :
    backend_key => merge(backend, {
      project                  = coalesce(backend.project, local.project)
      host_project             = coalesce(backend.host_project, var.host_project_id, var.host_project, local.project)
      region                   = try(coalesce(backend.region, var.region), null)
      name                     = coalesce(backend.name, var.name_prefix != null ? "${var.name_prefix}-${backend_key}" : backend_key)
      protocol                 = try(coalesce(backend.protocol, var.backend_protocol), null)
      existing_security_policy = try(coalesce(backend.existing_security_policy, var.existing_security_policy), null)
      security_policy          = try(coalesce(backend.security_policy, var.security_policy), null)
    })
  }
}

# Network Endpoint Groups
locals {
  negs = flatten(concat(
    [for backend_key, backend in local._backends :
      # Explicit NEGs defined by objects
      [for neg_key, neg in coalesce(lookup(backend, "negs", null), {}) :
        merge(neg, {
          neg_key      = neg_key
          project      = backend.project
          host_project = backend.host_project
          name         = coalesce(neg.name, neg_key)
          network      = try(coalesce(neg.network, backend.network, var.network), null)
          subnetwork   = try(coalesce(neg.subnetwork, backend.subnetwork, var.subnetwork), null)
          default_port = try(coalesce(lookup(neg, "default_port", null), lookup(neg, "port", null), backend.port), null)
          backend_key  = backend_key
          endpoints = concat(
            # Explicit Endpoints
            [for endpoint in coalesce(lookup(neg, "endpoints", null), []) :
              {
                ip_address = try(coalesce(lookup(endpoint, "ip_address", null), lookup(neg, "ip_address", null)), null)
                fqdn       = try(coalesce(lookup(endpoint, "fqdn", null), lookup(neg, "fqdn", null)), null)
                instance   = lookup(endpoint, "instance", null)
              }
            ],
            # Implicit Endpoints derived from the NEG object
            length(compact([for _ in ["ip_address", "fqdn", "instance"] : lookup(neg, _, null)])) > 0 ? [
              {
                ip_address = neg.ip_address
                fqdn       = neg.fqdn
                instance   = neg.instance
              }
            ] : []
          )
        })
      ]
    ],
    # Implicit NEG using IP address, FQDN, PSC, or Serverless target
    [for backend_key, backend in local._backends :
      {
        project           = backend.project
        host_project      = backend.host_project
        name              = backend.name
        network           = try(coalesce(backend.network, var.network), null)
        subnetwork        = try(coalesce(backend.subnetwork, var.subnetwork), null)
        default_port      = backend.port
        psc_target        = backend.psc_target
        cloud_run_service = backend.cloud_run_service
        region            = backend.region
        zone              = null
        backend_key       = backend_key
        neg_key           = 0
        endpoints = [
          {
            ip_address = backend.ip_address
            fqdn       = backend.fqdn
            port       = backend.port
          }
        ]
      } if length(compact([for _ in ["ip_address", "fqdn", "psc_target", "cloud_run_service"] : lookup(backend, _, null)])) > 0
    ]
  ))
}
module "negs" {
  source            = "../modules/neg"
  for_each          = { for neg_key, neg in local.negs : "${neg.backend_key}/${neg.neg_key}" => neg }
  project           = each.value.project
  host_project      = each.value.host_project
  name              = each.value.name
  region            = each.value.region
  zone              = each.value.zone
  network           = each.value.network
  subnetwork        = each.value.subnetwork
  default_port      = each.value.default_port
  psc_target        = each.value.psc_target
  cloud_run_service = each.value.cloud_run_service
  endpoints         = each.value.endpoints
}

# Cloud Armor Security Policies
locals {
  security_policies = { for k, v in var.security_policies : k =>
    merge(v, {
      project_id   = coalesce(v.project_id, var.project_id)
      name         = coalesce(v.name, var.name_prefix != null ? "${var.name_prefix}-${k}" : k)
      description  = v.description
      layer_7_ddos = coalesce(v.layer_7_ddos, false)
      rules        = [for rule in lookup(v, "rules", []) : rule]
    })
  }
}
module "cloudarmor" {
  source       = "../modules/cloudarmor"
  for_each     = { for k, v in local.security_policies : k => v }
  project_id   = each.value.project_id
  name         = each.value.name
  description  = each.value.description
  layer_7_ddos = each.value.layer_7_ddos
  rules        = each.value.rules
}

locals {
  backends = { for backend_key, backend in local._backends : backend_key =>
    merge(backend, {
      name        = coalesce(backend.name, backend_key)
      description = trimspace(coalesce(backend.description, "Managed by Terraform"))
      type        = local.type
      name_prefix = var.name_prefix
      groups = concat(coalesce(
        backend.groups,
        [for neg in local.negs : module.negs["${neg.backend_key}/${neg.neg_key}"].self_link if neg.backend_key == backend_key]
      ))
      timeout = try(coalesce(backend.timeout, var.backend_timeout), null)
      security_policy = one(coalescelist(
        [backend.existing_security_policy],
        [for sp_key, sp in local.security_policies : module.cloudarmor[backend.security_policy].self_link if backend.security_policy == sp_key]
      ))
      session_affinity            = try(coalesce(backend.session_affinity, var.session_affinity), null)
      locality_lb_policy          = try(coalesce(backend.locality_lb_policy, var.locality_lb_policy), null)
      ip_address_selection_policy = try(coalesce(backend.ip_address_selection_policy, var.backend_ip_address_selection_policy), null)
      is_ig                       = length(coalesce(backend.instance_groups, {})) > 0 ? true : false
      classic                     = coalesce(backend.classic, var.classic)
      health_checks               = [for hc in keys(local.health_checks) : module.healthchecks[hc].self_link if hc == backend.health_check]
      negs                        = backend.negs
      network                     = try(coalesce(backend.network, var.network), null)
      subnetwork                  = try(coalesce(backend.subnetwork, var.subnetwork), null)
      logging                     = try(coalesce(backend.logging, var.logging), null)
    })
  }
}
# Backend Services, Buckets, and Network Endpoint Groups
module "backends" {
  source                       = "../modules/lb-backend-new"
  for_each                     = { for k, v in local.backends : k => v }
  project_id                   = each.value.project
  host_project_id              = each.value.host_project
  region                       = each.value.region
  type                         = each.value.type
  name                         = each.value.name
  description                  = each.value.description
  port                         = each.value.port
  protocol                     = each.value.protocol
  network                      = each.value.network
  subnetwork                   = each.value.subnetwork
  groups                       = each.value.groups
  cdn                          = each.value.cdn
  security_policy              = each.value.security_policy
  timeout                      = each.value.timeout
  session_affinity             = each.value.session_affinity
  locality_lb_policy           = each.value.locality_lb_policy
  logging                      = each.value.logging
  classic                      = each.value.classic
  health_checks                = each.value.health_checks
  balancing_mode               = each.value.balancing_mode
  capacity_scaler              = each.value.capacity_scaler
  max_utilization              = each.value.max_utilization
  max_rate                     = each.value.max_rate
  max_rate_per_instance        = each.value.max_rate_per_instance
  max_rate_per_endpoint        = each.value.max_rate_per_endpoint
  max_connections              = each.value.max_connections
  max_connections_per_instance = each.value.max_connections_per_instance
  max_connections_per_endpoint = each.value.max_connections_per_endpoint
}

locals {
  frontends = { for k, v in var.frontends : k =>
    merge(v, {
      name                   = k == "default" ? coalesce(var.name_prefix, v.name, k) : coalesce(v.name, k)
      project_id             = coalesce(v.project_id, var.project_id)
      host_project_id        = try(coalesce(v.host_project_id, var.host_project_id), null)
      region                 = try(coalesce(v.region, var.region), null)
      type                   = local.type
      name_prefix            = k == "default" ? null : var.name_prefix
      redirect_http_to_https = try(coalesce(v.redirect_http_to_https, var.redirect_http_to_https), null)
      existing_ssl_certs     = v.existing_ssl_certs
      global_access          = try(coalesce(v.global_access, var.global_access), null)
      default_service        = v.default_service != null ? module.backends[v.default_service].name : length(local.backends) > 0 ? module.backends[keys(local.backends)[0]].name : "default"
      classic                = try(coalesce(v.classic, var.classic), null)
      existing_ssl_policy    = try(coalesce(v.existing_ssl_policy, var.existing_ssl_policy), null)
      ssl_certs = [for cert_key, cert in coalesce(v.ssl_certs, {}) :
        merge(cert, {
          name = coalesce(cert.name, var.name_prefix != null ? "${var.name_prefix}-${cert_key}" : cert_key)
        })
      ]
      routing_rules = [for rule_key, rule in coalesce(v.routing_rules, {}) :
        merge(rule, {
          name    = coalesce(rule.name, rule_key)
          backend = rule.backend != null ? module.backends[rule.backend].name : lookup(module.backends, rule_key, null) != null ? module.backends[rule_key].name : null
        })
      ]
      network    = try(coalesce(v.network, var.network), null)
      subnetwork = try(coalesce(v.subnetwork, var.subnetwork), null)
    })
  }
}


/*
locals {
  _domains = {
    test = {
      create = true
      name = "gcp-whamola-net"
      domain = "gcp.whamola.net"
      description = "Test"
      labels = {}
      scope = null
    }
  }
  scope = "DEFAULT"
  domains = {
    for k, v in local._domains :
    k => {
      create      = coalesce(v.create, true)
      name        = lower(replace(replace(coalesce(v.name, v.domain, k), ".", "-"), "*", "wildcard"))
      description = v.description
      domain      = lower(replace(replace(coalesce(v.domain, v.name, k), "-", "."), "wildcard", "*"))
      scope       = upper(coalesce(v.scope, local.scope))
      labels      = { for k, v in coalesce(v.labels, {}) : k => lower(v) }
    }
  }
}

resource "google_certificate_manager_dns_authorization" "default" {
  for_each    = { for k, v in local.domains : k => v if v.create }
  name        = each.value.name
  description = each.value.description
  domain      = each.value.domain
  labels      = each.value.labels
}

resource "google_certificate_manager_certificate" "default" {
  for_each    = { for k, v in local.domains : k => v if v.create }
  name        = each.value.name
  description = each.value.description
  scope       = each.value.scope
  labels      = each.value.labels
  managed {
    domains = [
      google_certificate_manager_dns_authorization.default[each.key].domain
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default[each.key].id
    ]
  }
}
*/

# Frontends (Forwarding Rules, Target Proxies, URL maps, etc)
module "frontends" {
  source                    = "../modules/lb-frontend"
  for_each                  = { for k, v in local.frontends : k => v }
  project_id                = each.value.project_id
  host_project_id           = each.value.host_project_id
  region                    = each.value.region
  type                      = each.value.type
  name_prefix               = each.value.name_prefix
  name                      = each.value.name
  description               = each.value.description
  network                   = each.value.network
  subnetwork                = each.value.subnetwork
  create_static_ip          = each.value.create_static_ip
  ip_address                = each.value.ip_address
  ip_address_name           = each.value.ip_address_name
  ip_address_description    = each.value.ip_address_description
  ipv4_address_name         = each.value.ipv4_address_name
  ipv6_address_name         = each.value.ipv6_address_name
  forwarding_rule_name      = each.value.forwarding_rule_name
  ipv4_forwarding_rule_name = each.value.ipv4_forwarding_rule_name
  ipv6_forwarding_rule_name = each.value.ipv6_forwarding_rule_name
  redirect_http_to_https    = each.value.redirect_http_to_https
  global_access             = each.value.global_access
  default_service           = each.value.default_service
  routing_rules             = each.value.routing_rules
  psc                       = each.value.psc
  ssl_policy                = each.value.ssl_policy
  existing_ssl_policy       = each.value.existing_ssl_policy
  classic                   = each.value.classic
  ssl_certs                 = each.value.ssl_certs
  existing_ssl_certs        = each.value.existing_ssl_certs
  depends_on                = [module.backends]
}

