<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

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
| <a name="input_create"></a> [create](#input\_create) | Whether or not to build forwarding rule | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the IP Address for the PSC Endpoint | `string` | `null` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | Allow access to forwarding rule from all regions | `bool` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the PSC Endpoint and IP Address | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Local VPC Network Name | `string` | `"default"` | no |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | If using Shared VPC, the GCP Project ID for the host network | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID to create resources in | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region name for the IP address and forwarding rule | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnetwork ID (projects/PROJECT\_ID/regions/REGION/subnetworks/SUBNET\_NAME) | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnetwork Name | `string` | `"default"` | no |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | ID of the published service (projects/PUBLISHER\_PROJECT\_ID/regions/REGION/serviceAttachments/SERVICE\_NAME) | `string` | `null` | no |
| <a name="input_target_name"></a> [target\_name](#input\_target\_name) | Name of the published service | `string` | `null` | no |
| <a name="input_target_project_id"></a> [target\_project\_id](#input\_target\_project\_id) | Project ID of the published service | `string` | `null` | no |
| <a name="input_target_region"></a> [target\_region](#input\_target\_region) | Region of the published service | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_address_name"></a> [address\_name](#output\_address\_name) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_psc_connection_id"></a> [psc\_connection\_id](#output\_psc\_connection\_id) | n/a |
<!-- END_TF_DOCS -->