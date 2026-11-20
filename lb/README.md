<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.5 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.5 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_cloud_run_service_iam_member.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_backend_bucket.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket) | resource |
| [google_compute_backend_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_forwarding_rule.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_forwarding_rule.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_network_endpoint.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_network_endpoint) | resource |
| [google_compute_global_network_endpoint_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_network_endpoint_group) | resource |
| [google_compute_health_check.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_instance_group_named_port.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_named_port) | resource |
| [google_compute_managed_ssl_certificate.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_compute_region_backend_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_health_check.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |
| [google_compute_region_network_endpoint_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group) | resource |
| [google_compute_region_ssl_certificate.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_ssl_certificate) | resource |
| [google_compute_region_ssl_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_ssl_policy) | resource |
| [google_compute_region_target_http_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_http_proxy) | resource |
| [google_compute_region_target_https_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_https_proxy) | resource |
| [google_compute_region_url_map.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_url_map) | resource |
| [google_compute_region_url_map.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_url_map) | resource |
| [google_compute_service_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |
| [google_compute_ssl_certificate.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate) | resource |
| [google_compute_ssl_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) | resource |
| [google_compute_target_http_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_target_https_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_target_tcp_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_tcp_proxy) | resource |
| [google_compute_url_map.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_compute_url_map.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_iap_brand.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_brand) | resource |
| [google_iap_client.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client) | resource |
| [google_iap_web_backend_service_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_backend_service_iam_binding) | resource |
| [null_resource.global_ssl_cert](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.regional_ssl_cert](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.name_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_affinity_type"></a> [affinity\_type](#input\_affinity\_type) | Session Affinity type all backends (can be overrriden on individual backends) | `string` | `null` | no |
| <a name="input_all_ports"></a> [all\_ports](#input\_all\_ports) | Accept traffic on all ports (Network LBs only) | `bool` | `false` | no |
| <a name="input_backend_logging"></a> [backend\_logging](#input\_backend\_logging) | Log requests to all backends (can be overridden on individual backends) | `bool` | `null` | no |
| <a name="input_backend_timeout"></a> [backend\_timeout](#input\_backend\_timeout) | Default timeout for all backends in seconds (can be overridden on individual backends) | `number` | `30` | no |
| <a name="input_backends"></a> [backends](#input\_backends) | Map of all backend services & buckets | <pre>list(object({<br/>    create             = optional(bool)<br/>    name               = optional(string)<br/>    type               = optional(string) # We'll try and figure it out automatically<br/>    description        = optional(string)<br/>    region             = optional(string)<br/>    bucket_name        = optional(string)<br/>    psc_target         = optional(string)<br/>    port               = optional(number)<br/>    port_name          = optional(string)<br/>    protocol           = optional(string)<br/>    enable_cdn         = optional(bool)<br/>    cdn_cache_mode     = optional(string)<br/>    timeout            = optional(number)<br/>    logging            = optional(bool)<br/>    logging_rate       = optional(number)<br/>    affinity_type      = optional(string)<br/>    locality_lb_policy = optional(string)<br/>    cloudarmor_policy  = optional(string)<br/>    healthcheck        = optional(string)<br/>    healthcheck_names  = optional(list(string))<br/>    healthchecks = optional(list(object({<br/>      id     = optional(string)<br/>      name   = optional(string)<br/>      region = optional(string)<br/>    })))<br/>    groups = optional(list(string)) # List of Instance Group or NEG IDs<br/>    instance_groups = optional(list(object({<br/>      id        = optional(string)<br/>      name      = optional(string)<br/>      zone      = optional(string)<br/>      instances = optional(list(string))<br/>    })))<br/>    rnegs = optional(list(object({<br/>      region                = optional(string)<br/>      psc_target            = optional(string)<br/>      network_name          = optional(string)<br/>      subnet_name           = optional(string)<br/>      cloud_run_name        = optional(string) # Cloud run service name<br/>      app_engine_name       = optional(string) # App Engine service name<br/>      container_image       = optional(string) # Default to GCR if not full URL<br/>      docker_image          = optional(string) # Pull image from docker.io<br/>      container_port        = optional(number) # Cloud run container port<br/>      allow_unauthenticated = optional(bool)<br/>      allowed_members       = optional(list(string))<br/>    })))<br/>    ineg = optional(object({<br/>      fqdn       = optional(string)<br/>      ip_address = optional(string)<br/>      port       = optional(number)<br/>    }))<br/>    iap = optional(object({<br/>      application_title = optional(string)<br/>      support_email     = optional(string)<br/>      members           = optional(list(string))<br/>    }))<br/>    capacity_scaler             = optional(number)<br/>    max_utilization             = optional(number)<br/>    max_rate_per_instance       = optional(number)<br/>    max_connections             = optional(number)<br/>    connection_draining_timeout = optional(number)<br/>    custom_request_headers      = optional(list(string))<br/>    custom_response_headers     = optional(list(string))<br/>  }))</pre> | <pre>[<br/>  {<br/>    "ineg": {<br/>      "fqdn": "teapotme.com"<br/>    },<br/>    "name": "example"<br/>  }<br/>]</pre> | no |
| <a name="input_cdn_cache_mode"></a> [cdn\_cache\_mode](#input\_cdn\_cache\_mode) | CDN caching mode for all backends (can be overrriden on individual backends) | `string` | `null` | no |
| <a name="input_classic"></a> [classic](#input\_classic) | Create Classic Load Balancer (or instead use envoy-based platform) | `bool` | `false` | no |
| <a name="input_cloudarmor_policy"></a> [cloudarmor\_policy](#input\_cloudarmor\_policy) | Cloud Armor Policy name to apply to all backends (can be overridden on individual backends) | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | End Backend Settings | `bool` | `true` | no |
| <a name="input_default_backend"></a> [default\_backend](#input\_default\_backend) | Default backend key to send traffic to. If not provided, first backend key will be used | `string` | `null` | no |
| <a name="input_default_service_id"></a> [default\_service\_id](#input\_default\_service\_id) | n/a | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for this Load Balancer | `string` | `null` | no |
| <a name="input_domains"></a> [domains](#input\_domains) | n/a | `list(string)` | `null` | no |
| <a name="input_enable_cdn"></a> [enable\_cdn](#input\_enable\_cdn) | Enable CDN for all backends (can be overrriden on individual backends) | `bool` | `null` | no |
| <a name="input_enable_ipv4"></a> [enable\_ipv4](#input\_enable\_ipv4) | n/a | `bool` | `true` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | n/a | `bool` | `false` | no |
| <a name="input_forwarding_rule_name"></a> [forwarding\_rule\_name](#input\_forwarding\_rule\_name) | Name For the forwarding Rule | `string` | `null` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | n/a | `bool` | `false` | no |
| <a name="input_healthchecks"></a> [healthchecks](#input\_healthchecks) | n/a | <pre>list(object({<br/>    create              = optional(bool, true)<br/>    project_id          = optional(string)<br/>    name                = optional(string)<br/>    description         = optional(string)<br/>    region              = optional(string)<br/>    port                = optional(number, 80)<br/>    protocol            = optional(string)<br/>    interval            = optional(number, 10)<br/>    timeout             = optional(number, 5)<br/>    healthy_threshold   = optional(number, 2)<br/>    unhealthy_threshold = optional(number, 2)<br/>    request_path        = optional(string)<br/>    response            = optional(string)<br/>    host                = optional(string)<br/>    legacy              = optional(bool)<br/>    logging             = optional(bool)<br/>    proxy_header        = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | HTTP port for LB Frontend | `number` | `80` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | HTTPS port for LB Frontend | `number` | `443` | no |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | n/a | `string` | `null` | no |
| <a name="input_ip_address_name"></a> [ip\_address\_name](#input\_ip\_address\_name) | n/a | `string` | `null` | no |
| <a name="input_ipv4_address"></a> [ipv4\_address](#input\_ipv4\_address) | n/a | `string` | `null` | no |
| <a name="input_ipv6_address"></a> [ipv6\_address](#input\_ipv6\_address) | n/a | `string` | `null` | no |
| <a name="input_key_algorithm"></a> [key\_algorithm](#input\_key\_algorithm) | For self-signed cert, the Algorithm for the Private Key | `string` | `"RSA"` | no |
| <a name="input_key_bits"></a> [key\_bits](#input\_key\_bits) | For self-signed cert, the number for bits for the private key | `number` | `2048` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels For the forwarding Rule | `map(string)` | `null` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | If creating SSL profile, the Minimum TLS Version to allow | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name Prefix for this Load Balancer | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | n/a | `string` | `null` | no |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_port_range"></a> [port\_range](#input\_port\_range) | n/a | `string` | `null` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | List of Ports Accept traffic on all ports (Network LBs only) | `list(number)` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_psc"></a> [psc](#input\_psc) | Parameters to publish Internal forwarding rule using PSC | <pre>object({<br/>    service_name                = optional(string)<br/>    description                 = optional(string)<br/>    nat_subnet_ids              = optional(list(string))<br/>    nat_subnet_names            = optional(list(string))<br/>    use_proxy_protocol          = optional(bool)<br/>    auto_accept_all_connections = optional(bool)<br/>    accept_project_ids          = optional(list(string))<br/>    reject_project_ids          = optional(list(string))<br/>    connection_limit            = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_quic_override"></a> [quic\_override](#input\_quic\_override) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP Region Name (regional LB only) | `string` | `null` | no |
| <a name="input_routing_rules"></a> [routing\_rules](#input\_routing\_rules) | Route rules to send different hostnames/paths to different backends | <pre>list(object({<br/>    create                    = optional(bool)<br/>    name                      = optional(string)<br/>    priority                  = optional(number)<br/>    hosts                     = list(string)<br/>    backend                   = optional(string)<br/>    backend_name              = optional(string)<br/>    path                      = optional(string)<br/>    request_headers_to_remove = optional(list(string))<br/>    path_rules = optional(list(object({<br/>      paths        = list(string)<br/>      backend_name = optional(string)<br/>      backend      = string<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_ssc_ca_org"></a> [ssc\_ca\_org](#input\_ssc\_ca\_org) | For self-signed certs, the name of the fake issuing CA | `string` | `null` | no |
| <a name="input_ssc_valid_years"></a> [ssc\_valid\_years](#input\_ssc\_valid\_years) | For self-signed certs, the number of years they should be valid for | `number` | `null` | no |
| <a name="input_ssl_cert_names"></a> [ssl\_cert\_names](#input\_ssl\_cert\_names) | List of existing SSL certificates to apply to this load balancer frontend | `list(string)` | `null` | no |
| <a name="input_ssl_certs"></a> [ssl\_certs](#input\_ssl\_certs) | List of SSL Certificates to upload to Google Certificate Manager | <pre>list(object({<br/>    create      = optional(bool)<br/>    name        = optional(string)<br/>    certificate = optional(string)<br/>    private_key = optional(string)<br/>    description = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_ssl_policy_name"></a> [ssl\_policy\_name](#input\_ssl\_policy\_name) | Name of pre-existing SSL Policy to Use for Frontend | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | n/a | `string` | `null` | no |
| <a name="input_tls_profile"></a> [tls\_profile](#input\_tls\_profile) | If creating SSL profile, the Browser Profile to use | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `null` | no |
| <a name="input_use_gmc"></a> [use\_gmc](#input\_use\_gmc) | Use Google-Managed Certs | `bool` | `false` | no |
| <a name="input_use_ssc"></a> [use\_ssc](#input\_use\_ssc) | Use Self-Signed Certs | `bool` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->