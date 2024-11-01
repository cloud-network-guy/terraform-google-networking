<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49, < 7.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.49, < 7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_dns_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_policy) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_enable_inbound_forwarding"></a> [enable\_inbound\_forwarding](#input\_enable\_inbound\_forwarding) | n/a | `bool` | `false` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | n/a | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | n/a | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_target_name_servers"></a> [target\_name\_servers](#input\_target\_name\_servers) | n/a | <pre>list(object({<br/>    ipv4_address    = string<br/>    forwarding_path = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_networks"></a> [networks](#output\_networks) | n/a |
<!-- END_TF_DOCS -->