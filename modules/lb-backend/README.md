# terraform-google-lb-backend
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16, < 7.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16, < 7.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_backend_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_region_backend_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_iap_brand.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_brand) | resource |
| [google_iap_client.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client) | resource |
| [google_iap_web_backend_service_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_backend_service_iam_binding) | resource |
| [null_resource.backend_service](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_balancing_mode"></a> [balancing\_mode](#input\_balancing\_mode) | n/a | `string` | `null` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | n/a | <pre>object({<br/>    name     = optional(string)<br/>    location = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_capacity_scaler"></a> [capacity\_scaler](#input\_capacity\_scaler) | n/a | `number` | `null` | no |
| <a name="input_cdn"></a> [cdn](#input\_cdn) | n/a | <pre>object({<br/>    cache_mode = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_classic"></a> [classic](#input\_classic) | n/a | `bool` | `false` | no |
| <a name="input_connection_draining_timeout_sec"></a> [connection\_draining\_timeout\_sec](#input\_connection\_draining\_timeout\_sec) | n/a | `number` | `300` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_custom_request_headers"></a> [custom\_request\_headers](#input\_custom\_request\_headers) | n/a | `list(string)` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_group"></a> [group](#input\_group) | n/a | `string` | `null` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | n/a | `list(string)` | `null` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | n/a | `string` | `null` | no |
| <a name="input_health_checks"></a> [health\_checks](#input\_health\_checks) | n/a | `list(string)` | `null` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_iap"></a> [iap](#input\_iap) | n/a | <pre>object({<br/>    create            = optional(bool)<br/>    application_title = optional(string)<br/>    support_email     = optional(string)<br/>    display_name      = optional(string)<br/>    members           = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_ip_address_selection_policy"></a> [ip\_address\_selection\_policy](#input\_ip\_address\_selection\_policy) | n/a | `string` | `null` | no |
| <a name="input_locality_lb_policy"></a> [locality\_lb\_policy](#input\_locality\_lb\_policy) | n/a | `string` | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | n/a | `bool` | `false` | no |
| <a name="input_logging_sample_rate"></a> [logging\_sample\_rate](#input\_logging\_sample\_rate) | n/a | `number` | `1` | no |
| <a name="input_max_connections"></a> [max\_connections](#input\_max\_connections) | n/a | `number` | `0` | no |
| <a name="input_max_connections_per_endpoint"></a> [max\_connections\_per\_endpoint](#input\_max\_connections\_per\_endpoint) | n/a | `number` | `0` | no |
| <a name="input_max_connections_per_instance"></a> [max\_connections\_per\_instance](#input\_max\_connections\_per\_instance) | n/a | `number` | `0` | no |
| <a name="input_max_rate"></a> [max\_rate](#input\_max\_rate) | n/a | `number` | `0` | no |
| <a name="input_max_rate_per_endpoint"></a> [max\_rate\_per\_endpoint](#input\_max\_rate\_per\_endpoint) | n/a | `number` | `0` | no |
| <a name="input_max_rate_per_instance"></a> [max\_rate\_per\_instance](#input\_max\_rate\_per\_instance) | n/a | `number` | `0` | no |
| <a name="input_max_utilization"></a> [max\_utilization](#input\_max\_utilization) | n/a | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | n/a | `number` | `null` | no |
| <a name="input_port_name"></a> [port\_name](#input\_port\_name) | n/a | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_security_policy"></a> [security\_policy](#input\_security\_policy) | n/a | `string` | `null` | no |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | n/a | `string` | `"NONE"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | n/a | `number` | `30` | no |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `"INTERNAL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_is_global"></a> [is\_global](#output\_is\_global) | n/a |
| <a name="output_is_psc"></a> [is\_psc](#output\_is\_psc) | n/a |
| <a name="output_is_regional"></a> [is\_regional](#output\_is\_regional) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
<!-- END_TF_DOCS -->