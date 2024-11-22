<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.5, < 7.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.11.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_network_security_gateway_security_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_gateway_security_policy) | resource |
| [google_network_security_gateway_security_policy_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_gateway_security_policy_rule) | resource |
| [google_network_security_url_lists.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_url_lists) | resource |
| [google_network_services_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_services_gateway) | resource |
| [null_resource.rules](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | n/a | `string` | `null` | no |
| <a name="input_addresses"></a> [addresses](#input\_addresses) | n/a | `list(string)` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | n/a | `number` | `null` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | n/a | `list(number)` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | List of manually controlled rules for this SWP Policy | <pre>list(object({<br/>    create              = optional(bool, true)<br/>    priority            = optional(number)<br/>    name                = optional(string)<br/>    description         = optional(string)<br/>    session_matcher     = optional(string)<br/>    application_matcher = optional(string)<br/>    basic_profile       = optional(string)<br/>    enabled             = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | `null` | no |
| <a name="input_url_list"></a> [url\_list](#input\_url\_list) | List of domains allow | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_addresses"></a> [gateway\_addresses](#output\_gateway\_addresses) | n/a |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | n/a |
| <a name="output_gateway_name"></a> [gateway\_name](#output\_gateway\_name) | n/a |
<!-- END_TF_DOCS -->