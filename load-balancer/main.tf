# Healthchecks
locals {
  health_checks = { for k, v in var.health_checks : k =>
    merge(v, {
      project_id = coalesce(v.project_id, var.project_id)
      name       = coalesce(v.name, var.name_prefix != null ? "${var.name_prefix}-${k}" : k)
      logging    = try(coalesce(v.logging, var.logging), null)
    })
  }
}
module "healthchecks" {
  source              = "../modules/healthcheck"
  for_each            = { for k, v in local.health_checks : k => v }
  project_id          = each.value.project_id
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
  _backends = { for k, v in var.backends :
    k => merge(v, {
      project_id      = coalesce(v.project_id, var.project_id)
      host_project_id = coalesce(v.host_project_id, var.host_project_id, var.project_id)
      region          = coalesce(v.region, var.region, "global")
      name            = coalesce(v.name, var.name_prefix != null ? "${var.name_prefix}-${k}" : k)
      protocol        = try(coalesce(v.protocol, var.backend_protocol), null)
      existing_security_policy = try(coalesce(v.existing_security_policy, var.existing_security_policy), null)
    })
  }
}

# Network Endpoint Groups
locals {
  negs = flatten(concat(
    [for k, v in local._backends :
      # Explicit NEGs defined by objects
      [for neg in coalesce(lookup(v, "negs", null), []) :
        merge(neg, {
          project_id      = v.project_id
          host_project_id = v.host_project_id
          name            = coalesce(neg.name, v.name)
          network         = try(coalesce(neg.network, v.network, var.network), null)
          subnet          = try(coalesce(neg.subnet, v.subnet, var.subnet), null)
          default_port    = try(coalesce(lookup(neg, "default_port", null), lookup(neg, "port", null), v.port), null)
          backend_key     = k
          endpoints = concat(
            # Explicit Endpoints
            [for e in coalesce(lookup(neg, "endpoints", null), []) :
              {
                ip_address = try(coalesce(lookup(e, "ip_address", null), lookup(neg, "ip_address", null)), null)
                fqdn       = try(coalesce(lookup(e, "fqdn", null), lookup(neg, "fqdn", null)), null)
                instance   = lookup(e, "instance", null)
              }
            ],
            # Implicit Endpoints derived from the NEG object
            neg.ip_address != null || neg.fqdn != null || neg.instance != null ? [
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
    [for k, v in local._backends :
      {
        project_id        = v.project_id
        host_project_id   = v.host_project_id
        name              = v.name
        network           = try(coalesce(v.network, var.network), null)
        subnet            = try(coalesce(v.subnet, var.subnet), null)
        default_port      = v.port
        psc_target        = v.psc_target
        cloud_run_service = v.cloud_run_service
        region            = v.region
        zone              = null
        backend_key       = k
        endpoints = [
          {
            ip_address = v.ip_address
            fqdn       = v.fqdn
            port       = v.port
          }
        ]
      } if v.ip_address != null || v.fqdn != null || v.psc_target != null || v.cloud_run_service != null
    ]
  ))
}
module "negs" {
  source            = "../modules/neg"
  for_each          = { for k, v in local.negs : v.backend_key => v }
  project_id        = each.value.project_id
  host_project_id   = each.value.host_project_id
  name              = each.value.name
  region            = each.value.region
  zone              = each.value.zone
  network           = each.value.network
  subnet            = each.value.subnet
  default_port      = each.value.default_port
  psc_target        = each.value.psc_target
  cloud_run_service = each.value.cloud_run_service
  endpoints         = each.value.endpoints
}

# Cloud Armor Security Policies
locals {
  security_policies = { for k, v in var.security_policies : k =>
    merge(v, {
      project_id  = coalesce(v.project_id, var.project_id)
      name        = coalesce(v.name, var.name_prefix != null ? "${var.name_prefix}-${k}" : k)
      description = v.description
      rules       = [for rule in lookup(v, "rules", []) : rule]
    })
  }
}
module "cloudarmor" {
  source      = "../modules/cloudarmor"
  for_each    = { for k, v in local.security_policies : k => v }
  project_id  = each.value.project_id
  name        = each.value.name
  description = each.value.description
  rules       = each.value.rules
}

locals {
  backends = { for k, v in local._backends : k =>
    merge(v, {
      name        = coalesce(v.name, k)
      type        = var.type
      name_prefix = var.name_prefix
      groups      = concat(coalesce(v.groups, [for i, v in local.negs : module.negs[v.backend_key].self_link if v.backend_key == k]))
      timeout     = try(coalesce(v.timeout, var.backend_timeout), null)
      security_policy = try(coalesce(
        v.existing_security_policy,
          v.security_policy != null ? module.cloudarmor[v.security_policy].self_link : null,
        var.security_policy != null ? module.cloudarmor[var.security_policy].self_link : null,
      ), null)
      session_affinity   = try(coalesce(v.session_affinity, var.session_affinity), null)
      locality_lb_policy = try(coalesce(v.locality_lb_policy, var.locality_lb_policy), null)
      is_ig              = length(coalesce(v.instance_groups, [])) > 0 ? true : false
      classic            = coalesce(v.classic, var.classic)
      health_checks      = [for hc in keys(local.health_checks) : module.healthchecks[hc].self_link if hc == v.health_check]
      negs               = v.negs
      network            = try(coalesce(v.network, var.network), null)
      subnet             = try(coalesce(v.subnet, var.subnet), null)
      logging            = try(coalesce(v.logging, var.logging), null)
    })
  }
}
# Backend Services, Buckets, and Network Endpoint Groups
module "backends" {
  source             = "../modules/lb-backend"
  for_each           = { for k, v in local.backends : k => v }
  project_id         = each.value.project_id
  host_project_id    = each.value.host_project_id
  region             = each.value.region
  type               = each.value.type
  name               = each.value.name
  description        = each.value.description
  port               = each.value.port
  protocol           = each.value.protocol
  network            = each.value.network
  subnet             = each.value.subnet
  groups             = each.value.groups
  cdn                = each.value.cdn
  security_policy    = each.value.security_policy
  timeout            = each.value.timeout
  session_affinity   = each.value.session_affinity
  locality_lb_policy = each.value.locality_lb_policy
  logging            = each.value.logging
  classic            = each.value.classic
  #health_check       = try(coalesce(each.value.existing_health_check, each.value.health_checks), null)
  health_checks = each.value.health_checks
  depends_on    = [module.healthchecks]
}

locals {
  frontends = { for k, v in var.frontends : k =>
    merge(v, {
      name                   = k == "default" ? coalesce(var.name_prefix, v.name, k) : coalesce(v.name, k)
      project_id             = coalesce(v.project_id, var.project_id)
      host_project_id        = try(coalesce(v.host_project_id, var.host_project_id), null)
      region                 = try(coalesce(v.region, var.region), null)
      type                   = var.type
      name_prefix            = k == "default" ? null : var.name_prefix
      redirect_http_to_https = try(coalesce(v.redirect_http_to_https, var.redirect_http_to_https), null)
      existing_ssl_certs     = v.existing_ssl_certs
      global_access          = try(coalesce(v.global_access, var.global_access), null)
      default_service        = coalesce(v.default_service, length(local.backends) > 0 ? module.backends[keys(local.backends)[0]].name : "default")
      classic                = try(coalesce(v.classic, var.classic), null)
      existing_ssl_policy    = try(coalesce(v.existing_ssl_policy, var.existing_ssl_policy), null)
      ssl_certs = [for cert_key, cert in coalesce(v.ssl_certs, {}) :
        merge(cert, {
          name = coalesce(cert.name, var.name_prefix != null ? "${var.name_prefix}-${cert_key}" : cert_key)
        })
      ]
      routing_rules = [for _, rule in coalesce(v.routing_rules, {}) :
        merge(rule, {
          name    = coalesce(rule.name, _)
          backend = module.backends[rule.backend].name
        })
      ]
      network = try(coalesce(v.network, var.network), null)
      subnet  = try(coalesce(v.subnet, var.subnet), null)
    })
  }
}

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
  subnet                    = each.value.subnet
  create_static_ip          = each.value.create_static_ip
  ip_address                = each.value.ip_address
  ip_address_name           = each.value.ip_address_name
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

