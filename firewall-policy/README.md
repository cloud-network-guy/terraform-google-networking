<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.37.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.16.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network_firewall_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy) | resource |
| [google_compute_network_firewall_policy_association.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_association) | resource |
| [google_compute_network_firewall_policy_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_region_network_firewall_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy) | resource |
| [google_compute_region_network_firewall_policy_association.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_association) | resource |
| [google_compute_region_network_firewall_policy_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_rule) | resource |
| [google_network_security_address_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_address_group) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_netblock_ip_ranges.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_groups"></a> [address\_groups](#input\_address\_groups) | n/a | <pre>map(object({<br/>    create      = optional(bool, true)<br/>    project_id  = optional(string)<br/>    org_id      = optional(number)<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    parent      = optional(string)<br/>    region      = optional(string)<br/>    type        = optional(string)<br/>    capacity    = optional(number)<br/>    items       = list(string)<br/>    labels      = optional(map(string))<br/>    ip_type     = optional(string, "IPV4")<br/>  }))</pre> | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | n/a | `list(string)` | `[]` | no |
| <a name="input_org"></a> [org](#input\_org) | n/a | `number` | `null` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | n/a | `number` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | n/a | <pre>list(object({<br/>    create                     = optional(bool, true)<br/>    priority                   = optional(number)<br/>    description                = optional(string)<br/>    direction                  = optional(string)<br/>    ip_type                    = optional(string, "IPV4")<br/>    ranges                     = optional(list(string))<br/>    range                      = optional(string)<br/>    source_ranges              = optional(list(string))<br/>    destination_ranges         = optional(list(string))<br/>    address_groups             = optional(list(string))<br/>    range_types                = optional(list(string))<br/>    range_type                 = optional(string)<br/>    protocol                   = optional(string)<br/>    protocols                  = optional(list(string))<br/>    port                       = optional(number)<br/>    ports                      = optional(list(number))<br/>    source_address_groups      = optional(list(string))<br/>    destination_address_groups = optional(list(string))<br/>    target_tags                = optional(list(string))<br/>    target_service_accounts    = optional(list(string))<br/>    action                     = optional(string)<br/>    logging                    = optional(bool)<br/>    disabled                   = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_rule_tuple_count"></a> [rule\_tuple\_count](#output\_rule\_tuple\_count) | n/a |
<!-- END_TF_DOCS -->