# terraform-google-lb-backend
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 7.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16.0, < 7.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_backend_bucket.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket) | resource |
| [google_compute_backend_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_region_backend_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_iap_brand.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_brand) | resource |
| [google_iap_client.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client) | resource |
| [google_iap_web_backend_service_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_backend_service_iam_binding) | resource |
| [google_storage_bucket.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [null_resource.backend_services](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | n/a | <pre>object({<br/>    #create   = optional(bool)<br/>    name     = optional(string)<br/>    location = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_bucket_location"></a> [bucket\_location](#input\_bucket\_location) | n/a | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | n/a | `string` | `null` | no |
| <a name="input_capacity_scaler"></a> [capacity\_scaler](#input\_capacity\_scaler) | n/a | `number` | `null` | no |
| <a name="input_cdn"></a> [cdn](#input\_cdn) | n/a | <pre>object({<br/>    cache_mode = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_classic"></a> [classic](#input\_classic) | n/a | `bool` | `null` | no |
| <a name="input_connection_draining_timeout"></a> [connection\_draining\_timeout](#input\_connection\_draining\_timeout) | n/a | `number` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `null` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | n/a | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | n/a | `list(string)` | `null` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | n/a | `string` | `null` | no |
| <a name="input_health_checks"></a> [health\_checks](#input\_health\_checks) | n/a | `list(string)` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_iap"></a> [iap](#input\_iap) | n/a | <pre>object({<br/>    application_title = optional(string)<br/>    support_email     = optional(string)<br/>    members           = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_locality_lb_policy"></a> [locality\_lb\_policy](#input\_locality\_lb\_policy) | n/a | `string` | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | n/a | `bool` | `null` | no |
| <a name="input_max_connections"></a> [max\_connections](#input\_max\_connections) | n/a | `number` | `null` | no |
| <a name="input_max_rate_per_instance"></a> [max\_rate\_per\_instance](#input\_max\_rate\_per\_instance) | n/a | `number` | `null` | no |
| <a name="input_max_utilization"></a> [max\_utilization](#input\_max\_utilization) | n/a | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | n/a | `number` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_security_policy"></a> [security\_policy](#input\_security\_policy) | n/a | `string` | `null` | no |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | n/a | `string` | `null` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | n/a | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | n/a | `number` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_services"></a> [backend\_services](#output\_backend\_services) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
<!-- END_TF_DOCS -->