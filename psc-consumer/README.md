<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 8.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_psc-endpoint"></a> [psc-endpoint](#module\_psc-endpoint) | ../modules/forwarding-rule | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | n/a | `string` | `null` | no |
| <a name="input_address_description"></a> [address\_description](#input\_address\_description) | n/a | `string` | `null` | no |
| <a name="input_address_name"></a> [address\_name](#input\_address\_name) | n/a | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | n/a | `bool` | `false` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_set_null_subnetwork"></a> [set\_null\_subnetwork](#input\_set\_null\_subnetwork) | Set subnetwork attribute to null for forwarding rule | `bool` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | `null` | no |
| <a name="input_target"></a> [target](#input\_target) | PSC Target | `string` | `null` | no |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | PSC Target ID | `string` | `null` | no |
| <a name="input_target_name"></a> [target\_name](#input\_target\_name) | PSC Target Service Name | `string` | `null` | no |
| <a name="input_target_project"></a> [target\_project](#input\_target\_project) | PSC Target Project ID | `string` | `null` | no |
| <a name="input_target_region"></a> [target\_region](#input\_target\_region) | PSC Target Service Region | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_address_name"></a> [address\_name](#output\_address\_name) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_psc_connection_id"></a> [psc\_connection\_id](#output\_psc\_connection\_id) | n/a |
| <a name="output_target"></a> [target](#output\_target) | n/a |
<!-- END_TF_DOCS -->