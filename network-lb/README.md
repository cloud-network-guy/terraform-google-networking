<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.5, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.5, < 7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backends"></a> [backends](#module\_backends) | ../modules/lb-backend-new | n/a |
| <a name="module_frontends"></a> [frontends](#module\_frontends) | ../modules/forwarding-rule | n/a |
| <a name="module_healthchecks"></a> [healthchecks](#module\_healthchecks) | ../modules/healthcheck | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_protocol"></a> [backend\_protocol](#input\_backend\_protocol) | n/a | `string` | `null` | no |
| <a name="input_backend_timeout"></a> [backend\_timeout](#input\_backend\_timeout) | n/a | `number` | `null` | no |
| <a name="input_backends"></a> [backends](#input\_backends) | n/a | <pre>map(object({<br/>    create                   = optional(bool, true)<br/>    project_id               = optional(string)<br/>    host_project_id          = optional(string)<br/>    name                     = optional(string)<br/>    description              = optional(string)<br/>    region                   = optional(string)<br/>    port                     = optional(number)<br/>    protocol                 = optional(string)<br/>    timeout                  = optional(number)<br/>    logging                  = optional(bool)<br/>    enable_cdn               = optional(bool)<br/>    enable_iap               = optional(bool)<br/>    health_check             = optional(string)<br/>    health_checks            = optional(list(string))<br/>    existing_health_check    = optional(string)<br/>    security_policy          = optional(string)<br/>    existing_security_policy = optional(string)<br/>    session_affinity         = optional(string)<br/>    locality_lb_policy       = optional(string)<br/>    classic                  = optional(bool)<br/>    network                  = optional(string)<br/>    subnetwork               = optional(string)<br/>    groups                   = optional(list(string))<br/>    ip_address               = optional(string)<br/>    fqdn                     = optional(string)<br/>    psc_target               = optional(string)<br/>    cloud_run_service        = optional(string)<br/>    instance_groups = optional(list(object({<br/>      id         = optional(string)<br/>      project_id = optional(string)<br/>      zone       = optional(string)<br/>      name       = optional(string)<br/>    })))<br/>    negs = optional(list(object({<br/>      name              = optional(string)<br/>      network           = optional(string)<br/>      subnet            = optional(string)<br/>      region            = optional(string)<br/>      zone              = optional(string)<br/>      instance          = optional(string)<br/>      fqdn              = optional(string)<br/>      ip_address        = optional(string)<br/>      port              = optional(number)<br/>      default_port      = optional(number)<br/>      psc_target        = optional(string)<br/>      cloud_run_service = optional(string)<br/>      endpoints = optional(list(object({<br/>        instance   = optional(string)<br/>        fqdn       = optional(string)<br/>        ip_address = optional(string)<br/>        port       = optional(number)<br/>      })))<br/>    })))<br/>    cdn = optional(object({<br/>      cache_mode = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_classic"></a> [classic](#input\_classic) | n/a | `bool` | `false` | no |
| <a name="input_create_service_label"></a> [create\_service\_label](#input\_create\_service\_label) | n/a | `bool` | `null` | no |
| <a name="input_existing_security_policy"></a> [existing\_security\_policy](#input\_existing\_security\_policy) | n/a | `string` | `null` | no |
| <a name="input_existing_ssl_policy"></a> [existing\_ssl\_policy](#input\_existing\_ssl\_policy) | n/a | `string` | `null` | no |
| <a name="input_frontends"></a> [frontends](#input\_frontends) | n/a | <pre>map(object({<br/>    create                = optional(bool, true)<br/>    project_id            = optional(string)<br/>    host_project_id       = optional(string)<br/>    region                = optional(string)<br/>    name                  = optional(string)<br/>    description           = optional(string)<br/>    network               = optional(string)<br/>    subnetwork            = optional(string)<br/>    ports                 = optional(list(number))<br/>    backend               = optional(string)<br/>    create_static_ip      = optional(bool)<br/>    ip_address            = optional(string)<br/>    ipv4_address          = optional(string)<br/>    ipv6_address          = optional(string)<br/>    ip_address_name       = optional(string)<br/>    ipv4_address_name     = optional(string)<br/>    ipv6_address_name     = optional(string)<br/>    preserve_ip_addresses = optional(bool)<br/>    global_access         = optional(string)<br/>    create_service_label  = optional(bool)<br/>    service_label         = optional(string)<br/>    psc = optional(object({<br/>      create                   = optional(bool)<br/>      project_id               = optional(string)<br/>      host_project_id          = optional(string)<br/>      name                     = optional(string)<br/>      description              = optional(string)<br/>      forwarding_rule_name     = optional(string)<br/>      target_service_id        = optional(string)<br/>      nat_subnets              = optional(list(string))<br/>      enable_proxy_protocol    = optional(bool)<br/>      auto_accept_all_projects = optional(bool)<br/>      accept_project_ids = optional(list(object({<br/>        project_id       = string<br/>        connection_limit = optional(number)<br/>      })))<br/>      domain_names          = optional(list(string))<br/>      consumer_reject_lists = optional(list(string))<br/>      reconcile_connections = optional(bool)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | n/a | `bool` | `false` | no |
| <a name="input_health_checks"></a> [health\_checks](#input\_health\_checks) | n/a | <pre>map(object({<br/>    create              = optional(bool, true)<br/>    project_id          = optional(string)<br/>    name                = optional(string)<br/>    description         = optional(string)<br/>    region              = optional(string)<br/>    port                = optional(number)<br/>    protocol            = optional(string)<br/>    interval            = optional(number)<br/>    timeout             = optional(number)<br/>    healthy_threshold   = optional(number)<br/>    unhealthy_threshold = optional(number)<br/>    request_path        = optional(string)<br/>    response            = optional(string)<br/>    host                = optional(string)<br/>    legacy              = optional(bool)<br/>    logging             = optional(bool)<br/>    proxy_header        = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_locality_lb_policy"></a> [locality\_lb\_policy](#input\_locality\_lb\_policy) | n/a | `string` | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | n/a | `bool` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_preserve_ip_addresses"></a> [preserve\_ip\_addresses](#input\_preserve\_ip\_addresses) | n/a | `bool` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_redirect_http_to_https"></a> [redirect\_http\_to\_https](#input\_redirect\_http\_to\_https) | n/a | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_security_policy"></a> [security\_policy](#input\_security\_policy) | n/a | `string` | `null` | no |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | n/a | `string` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backends"></a> [backends](#output\_backends) | n/a |
| <a name="output_frontends"></a> [frontends](#output\_frontends) | n/a |
| <a name="output_health_checks"></a> [health\_checks](#output\_health\_checks) | n/a |
<!-- END_TF_DOCS -->