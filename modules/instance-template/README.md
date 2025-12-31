<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16.0, < 8.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_template.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [null_resource.instance_template](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.name_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_instance_name"></a> [base\_instance\_name](#input\_base\_instance\_name) | n/a | `string` | `null` | no |
| <a name="input_can_ip_forward"></a> [can\_ip\_forward](#input\_can\_ip\_forward) | n/a | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_disk"></a> [disk](#input\_disk) | n/a | <pre>object({<br/>    source_image = optional(string)<br/>    boot         = optional(bool)<br/>    auto_delete  = optional(bool)<br/>    type         = optional(string)<br/>    size_gb      = optional(number)<br/>    interface    = optional(string)<br/>    mode         = optional(string)<br/>    labels       = optional(map(string))<br/>  })</pre> | `{}` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | n/a | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | n/a | `string` | `"e2-micro"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | n/a | `map(string)` | <pre>{<br/>  "enable-osconfig": "true"<br/>}</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `"default"` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | n/a | `list(string)` | `null` | no |
| <a name="input_os"></a> [os](#input\_os) | n/a | `string` | `"debian-12"` | no |
| <a name="input_os_project"></a> [os\_project](#input\_os\_project) | n/a | `string` | `"debian-cloud"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | n/a | `string` | `null` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | n/a | `string` | `null` | no |
| <a name="input_service_account_scopes"></a> [service\_account\_scopes](#input\_service\_account\_scopes) | n/a | `list(string)` | <pre>[<br/>  "https://www.googleapis.com/auth/cloud-platform"<br/>]</pre> | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | n/a | `string` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | `"default"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
<!-- END_TF_DOCS -->