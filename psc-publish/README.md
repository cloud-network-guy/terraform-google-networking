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
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_service_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_accept_all_projects"></a> [auto\_accept\_all\_projects](#input\_auto\_accept\_all\_projects) | Set whether to auto-accept connections from any project | `bool` | `false` | no |
| <a name="input_consumer_accept_list"></a> [consumer\_accept\_list](#input\_consumer\_accept\_list) | List of Project IDs to accept connections from | <pre>list(object({<br/>    project          = string<br/>    connection_limit = optional(number, 10)<br/>  }))</pre> | `[]` | no |
| <a name="input_consumer_reject_list"></a> [consumer\_reject\_list](#input\_consumer\_reject\_list) | n/a | <pre>list(object({<br/>    project = string<br/>  }))</pre> | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the Published Service | `string` | `null` | no |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | n/a | `list(string)` | `[]` | no |
| <a name="input_enable_proxy_protocol"></a> [enable\_proxy\_protocol](#input\_enable\_proxy\_protocol) | enable the proxy protocol | `bool` | `false` | no |
| <a name="input_forwarding_rule_name"></a> [forwarding\_rule\_name](#input\_forwarding\_rule\_name) | Forwarding Rule Name to publish (must be in same project) | `string` | `null` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Published Service | `string` | `null` | no |
| <a name="input_nat_subnet"></a> [nat\_subnet](#input\_nat\_subnet) | n/a | `string` | `null` | no |
| <a name="input_nat_subnets"></a> [nat\_subnets](#input\_nat\_subnets) | n/a | `list(string)` | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `"default"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_reconcile_connections"></a> [reconcile\_connections](#input\_reconcile\_connections) | n/a | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region name | `string` | `null` | no |
| <a name="input_target_service"></a> [target\_service](#input\_target\_service) | Forwarding Rule Service ID to publish | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->