<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12.0, < 8.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_dns_managed_zone.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [null_resource.dns_record_set](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | n/a | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | n/a | `bool` | `false` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | n/a | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | n/a | `list(string)` | `null` | no |
| <a name="input_peer_network"></a> [peer\_network](#input\_peer\_network) | n/a | `string` | `null` | no |
| <a name="input_peer_network_id"></a> [peer\_network\_id](#input\_peer\_network\_id) | n/a | `string` | `null` | no |
| <a name="input_peer_project"></a> [peer\_project](#input\_peer\_project) | n/a | `string` | `null` | no |
| <a name="input_peer_project_id"></a> [peer\_project\_id](#input\_peer\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_records"></a> [records](#input\_records) | n/a | <pre>list(object({<br/>    create  = optional(bool, true)<br/>    name    = string<br/>    type    = optional(string)<br/>    ttl     = optional(number)<br/>    rrdatas = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_target_name_servers"></a> [target\_name\_servers](#input\_target\_name\_servers) | n/a | <pre>list(object({<br/>    ipv4_address    = string<br/>    forwarding_path = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_managed_zone_id"></a> [managed\_zone\_id](#output\_managed\_zone\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | n/a |
<!-- END_TF_DOCS -->