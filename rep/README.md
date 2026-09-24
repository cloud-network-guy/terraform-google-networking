<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.14.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.46.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_network_connectivity_regional_endpoint.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_connectivity_regional_endpoint) | resource |
| [null_resource.regional_endpoint](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | n/a | `string` | `null` | no |
| <a name="input_address_description"></a> [address\_description](#input\_address\_description) | n/a | `string` | `null` | no |
| <a name="input_address_name"></a> [address\_name](#input\_address\_name) | n/a | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_create_static_ip"></a> [create\_static\_ip](#input\_create\_static\_ip) | Create and use Static IP address | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | n/a | `bool` | `false` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the endpoint and the reserved address. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | n/a | yes |
| <a name="input_target_google_api"></a> [target\_google\_api](#input\_target\_google\_api) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the regional endpoint. |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | Internal IP address of the endpoint (use default for your private DNS record). |
| <a name="output_name"></a> [name](#output\_name) | Name of the regional endpoint. |
| <a name="output_psc_forwarding_rule"></a> [psc\_forwarding\_rule](#output\_psc\_forwarding\_rule) | Forwarding rule that the service created for default endpoint. |
| <a name="output_static_ip_address"></a> [static\_ip\_address](#output\_static\_ip\_address) | Reserved internal address resource details, or null when create\_address is false. |
| <a name="output_target_google_api"></a> [target\_google\_api](#output\_target\_google\_api) | Regional Google API the endpoint connects to. |
<!-- END_TF_DOCS -->