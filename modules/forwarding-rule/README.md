 
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
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_service_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |
| [null_resource.ip_addresses](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | n/a | `string` | `null` | no |
| <a name="input_address_description"></a> [address\_description](#input\_address\_description) | n/a | `string` | `null` | no |
| <a name="input_address_name"></a> [address\_name](#input\_address\_name) | n/a | `string` | `null` | no |
| <a name="input_all_ports"></a> [all\_ports](#input\_all\_ports) | n/a | `bool` | `null` | no |
| <a name="input_backend_service"></a> [backend\_service](#input\_backend\_service) | n/a | `string` | `null` | no |
| <a name="input_classic"></a> [classic](#input\_classic) | n/a | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_create_service_label"></a> [create\_service\_label](#input\_create\_service\_label) | n/a | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | n/a | `bool` | `false` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_network_tier"></a> [network\_tier](#input\_network\_tier) | n/a | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | n/a | `number` | `null` | no |
| <a name="input_port_range"></a> [port\_range](#input\_port\_range) | n/a | `string` | `null` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | n/a | `list(number)` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | n/a | `string` | `null` | no |
| <a name="input_psc"></a> [psc](#input\_psc) | Parameters to Publish this Frontend via PSC | <pre>object({<br/>    create                   = optional(bool)<br/>    host_project             = optional(string)<br/>    name                     = optional(string)<br/>    description              = optional(string)<br/>    nat_subnets              = optional(list(string))<br/>    enable_proxy_protocol    = optional(bool)<br/>    auto_accept_all_projects = optional(bool)<br/>    accept_projects = optional(list(object({<br/>      project          = string<br/>      connection_limit = optional(number)<br/>    })))<br/>    domain_names          = optional(list(string))<br/>    consumer_reject_lists = optional(list(string))<br/>    reconcile_connections = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_service_label"></a> [service\_label](#input\_service\_label) | n/a | `string` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | `null` | no |
| <a name="input_target"></a> [target](#input\_target) | n/a | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_address_name"></a> [address\_name](#output\_address\_name) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_psc_connected_endpoints"></a> [psc\_connected\_endpoints](#output\_psc\_connected\_endpoints) | n/a |
| <a name="output_psc_connection_id"></a> [psc\_connection\_id](#output\_psc\_connection\_id) | n/a |
| <a name="output_target"></a> [target](#output\_target) | n/a |
<!-- END_TF_DOCS -->