<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49.0, < 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.49.0, < 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [random_string.random_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Flag on wether to actually create this resource | `bool` | `true` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | Default Shared VPC Host Project (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Names of instances to have in this group | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of resource to create | `string` | `null` | no |
| <a name="input_named_ports"></a> [named\_ports](#input\_named\_ports) | List of Named Ports | <pre>list(object({<br/>    name = string<br/>    port = number<br/>  }))</pre> | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | Name or URL of VPC Network to use | `string` | `"default"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP Zone Name | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_index_key"></a> [index\_key](#output\_index\_key) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
| <a name="output_zone"></a> [zone](#output\_zone) | n/a |
<!-- END_TF_DOCS -->