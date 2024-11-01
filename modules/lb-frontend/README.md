<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16, < 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16, < 6.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_managed_ssl_certificate.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_compute_region_ssl_certificate.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_ssl_certificate) | resource |
| [google_compute_region_ssl_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_ssl_policy) | resource |
| [google_compute_region_target_http_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_http_proxy) | resource |
| [google_compute_region_target_https_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_https_proxy) | resource |
| [google_compute_region_target_tcp_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_tcp_proxy) | resource |
| [google_compute_region_url_map.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_url_map) | resource |
| [google_compute_service_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |
| [google_compute_ssl_certificate.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate) | resource |
| [google_compute_ssl_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) | resource |
| [google_compute_target_http_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_target_https_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_target_tcp_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_tcp_proxy) | resource |
| [google_compute_url_map.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [null_resource.ip_addresses](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ssl_certs](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.url_maps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.random_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_all_ports"></a> [all\_ports](#input\_all\_ports) | n/a | `bool` | `null` | no |
| <a name="input_classic"></a> [classic](#input\_classic) | n/a | `bool` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `null` | no |
| <a name="input_create_static_ip"></a> [create\_static\_ip](#input\_create\_static\_ip) | n/a | `bool` | `null` | no |
| <a name="input_default_service"></a> [default\_service](#input\_default\_service) | n/a | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_enable_http"></a> [enable\_http](#input\_enable\_http) | n/a | `bool` | `null` | no |
| <a name="input_enable_https"></a> [enable\_https](#input\_enable\_https) | n/a | `bool` | `null` | no |
| <a name="input_enable_ipv4"></a> [enable\_ipv4](#input\_enable\_ipv4) | n/a | `bool` | `null` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | n/a | `bool` | `null` | no |
| <a name="input_existing_ssl_certs"></a> [existing\_ssl\_certs](#input\_existing\_ssl\_certs) | n/a | `list(string)` | `null` | no |
| <a name="input_existing_ssl_policy"></a> [existing\_ssl\_policy](#input\_existing\_ssl\_policy) | n/a | `string` | `null` | no |
| <a name="input_forwarding_rule_name"></a> [forwarding\_rule\_name](#input\_forwarding\_rule\_name) | n/a | `string` | `null` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | n/a | `bool` | `false` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | If using Shared VPC, the GCP Project ID for the host network | `string` | `null` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | n/a | `number` | `null` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | n/a | `number` | `null` | no |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | n/a | `string` | `null` | no |
| <a name="input_ip_address_description"></a> [ip\_address\_description](#input\_ip\_address\_description) | n/a | `string` | `null` | no |
| <a name="input_ip_address_name"></a> [ip\_address\_name](#input\_ip\_address\_name) | n/a | `string` | `null` | no |
| <a name="input_ipv4_address"></a> [ipv4\_address](#input\_ipv4\_address) | n/a | `string` | `null` | no |
| <a name="input_ipv4_address_name"></a> [ipv4\_address\_name](#input\_ipv4\_address\_name) | n/a | `string` | `null` | no |
| <a name="input_ipv4_forwarding_rule_name"></a> [ipv4\_forwarding\_rule\_name](#input\_ipv4\_forwarding\_rule\_name) | n/a | `string` | `null` | no |
| <a name="input_ipv6_address"></a> [ipv6\_address](#input\_ipv6\_address) | n/a | `string` | `null` | no |
| <a name="input_ipv6_address_name"></a> [ipv6\_address\_name](#input\_ipv6\_address\_name) | n/a | `string` | `null` | no |
| <a name="input_ipv6_forwarding_rule_name"></a> [ipv6\_forwarding\_rule\_name](#input\_ipv6\_forwarding\_rule\_name) | n/a | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `null` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | n/a | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | n/a | `number` | `null` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | n/a | `list(number)` | `null` | no |
| <a name="input_preserve_ip"></a> [preserve\_ip](#input\_preserve\_ip) | n/a | `bool` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID to create resources in | `string` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | n/a | `string` | `null` | no |
| <a name="input_psc"></a> [psc](#input\_psc) | Parameters to Publish this Frontend via PSC | <pre>object({<br/>    create                   = optional(bool)<br/>    project_id               = optional(string)<br/>    host_project_id          = optional(string)<br/>    name                     = optional(string)<br/>    description              = optional(string)<br/>    forwarding_rule_name     = optional(string)<br/>    target_service_id        = optional(string)<br/>    nat_subnets              = optional(list(string))<br/>    enable_proxy_protocol    = optional(bool)<br/>    auto_accept_all_projects = optional(bool)<br/>    accept_project_ids = optional(list(object({<br/>      project_id       = string<br/>      connection_limit = optional(number)<br/>    })))<br/>    domain_names          = optional(list(string))<br/>    consumer_reject_lists = optional(list(string))<br/>    reconcile_connections = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_quic_override"></a> [quic\_override](#input\_quic\_override) | n/a | `bool` | `null` | no |
| <a name="input_redirect_http_to_https"></a> [redirect\_http\_to\_https](#input\_redirect\_http\_to\_https) | n/a | `bool` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region name for the IP address and forwarding rule | `string` | `null` | no |
| <a name="input_routing_rules"></a> [routing\_rules](#input\_routing\_rules) | List of Routing Rules for the URL Map | <pre>list(object({<br/>    create                    = optional(bool, true)<br/>    project_id                = optional(string)<br/>    name                      = optional(string)<br/>    priority                  = optional(number)<br/>    hosts                     = list(string)<br/>    backend                   = optional(string)<br/>    path                      = optional(string)<br/>    request_headers_to_remove = optional(list(string))<br/>    redirect = optional(object({<br/>      code        = optional(string)<br/>      host        = optional(string)<br/>      https       = optional(string)<br/>      strip_query = optional(bool)<br/>    }))<br/>    path_rules = optional(list(object({<br/>      paths        = list(string)<br/>      backend_name = optional(string)<br/>      backend      = string<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_ssl_certs"></a> [ssl\_certs](#input\_ssl\_certs) | List of SSL Certificates to upload to Google Certificate Manager | <pre>list(object({<br/>    create          = optional(bool, true)<br/>    project_id      = optional(string)<br/>    name            = optional(string)<br/>    description     = optional(string)<br/>    certificate     = optional(string)<br/>    private_key     = optional(string)<br/>    region          = optional(string)<br/>    domains         = optional(list(string))<br/>    ca_organization = optional(string)<br/>    ca_valid_years  = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Custom TLS policy | <pre>object({<br/>    create          = optional(bool)<br/>    project_id      = optional(string)<br/>    name            = optional(string)<br/>    description     = optional(string)<br/>    min_tls_version = optional(string)<br/>    tls_profile     = optional(string)<br/>    region          = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | n/a | `string` | `null` | no |
| <a name="input_target"></a> [target](#input\_target) | n/a | `string` | `null` | no |
| <a name="input_target_http_proxy_name"></a> [target\_http\_proxy\_name](#input\_target\_http\_proxy\_name) | n/a | `string` | `null` | no |
| <a name="input_target_https_proxy_name"></a> [target\_https\_proxy\_name](#input\_target\_https\_proxy\_name) | n/a | `string` | `null` | no |
| <a name="input_target_name"></a> [target\_name](#input\_target\_name) | n/a | `string` | `null` | no |
| <a name="input_target_region"></a> [target\_region](#input\_target\_region) | n/a | `string` | `null` | no |
| <a name="input_target_tcp_proxy_name"></a> [target\_tcp\_proxy\_name](#input\_target\_tcp\_proxy\_name) | n/a | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `null` | no |
| <a name="input_url_map_name"></a> [url\_map\_name](#input\_url\_map\_name) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |
| <a name="output_forwarding_rules"></a> [forwarding\_rules](#output\_forwarding\_rules) | n/a |
| <a name="output_ip_addresses"></a> [ip\_addresses](#output\_ip\_addresses) | n/a |
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | n/a |
| <a name="output_ipv6_address"></a> [ipv6\_address](#output\_ipv6\_address) | n/a |
| <a name="output_ssl_certs"></a> [ssl\_certs](#output\_ssl\_certs) | n/a |
<!-- END_TF_DOCS -->