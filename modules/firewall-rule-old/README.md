<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.49, < 7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [random_string.short_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_netblock_ip_ranges.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | Action (should be allow or deny) | `string` | `null` | no |
| <a name="input_allow"></a> [allow](#input\_allow) | List of protocols and ports (if applicable) to allow | <pre>list(object({<br/>    protocol = string<br/>    ports    = list(string)<br/>  }))</pre> | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_deny"></a> [deny](#input\_deny) | List of protocols and ports (if applicable) to deny | <pre>list(object({<br/>    protocol = string<br/>    ports    = list(string)<br/>  }))</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `"Created by Terraform"` | no |
| <a name="input_direction"></a> [direction](#input\_direction) | Direction (ingress or egress) | `string` | `null` | no |
| <a name="input_disabled"></a> [disabled](#input\_disabled) | Whether to actually enforce this rule | `bool` | `false` | no |
| <a name="input_enforcement"></a> [enforcement](#input\_enforcement) | Whether to actually enforce this rule | `bool` | `true` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Log hits to this rule | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for this Firewall Rule | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name Prefix for this rule.  Rest of name will be auto-generated | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Name of the VPC network rule applies to | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of the VPC network rule applies to | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | TCP or UDP Port to allow or deny | `number` | `null` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | TCP Ports to allow or deny | `list(string)` | `null` | no |
| <a name="input_priority"></a> [priority](#input\_priority) | Priority Number (lower number is higher priority) | `number` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Network Protocol (tcp, udp, icmp, esp, gre, etc) | `string` | `null` | no |
| <a name="input_protocols"></a> [protocols](#input\_protocols) | Network Protocols (plural).  Example: ["tcp", "udp"] | `list(string)` | `null` | no |
| <a name="input_range"></a> [range](#input\_range) | IP Range for this Rule | `string` | `null` | no |
| <a name="input_range_type"></a> [range\_type](#input\_range\_type) | n/a | `string` | `null` | no |
| <a name="input_range_types"></a> [range\_types](#input\_range\_types) | n/a | `list(string)` | `null` | no |
| <a name="input_ranges"></a> [ranges](#input\_ranges) | IP Ranges for this Rule | `list(string)` | `null` | no |
| <a name="input_short_name"></a> [short\_name](#input\_short\_name) | Short name for this rule.  Rule name will be var.name\_prefix + var.short\_name | `string` | `null` | no |
| <a name="input_source_service_accounts"></a> [source\_service\_accounts](#input\_source\_service\_accounts) | Source Service Accounts to match (ingress only) | `list(string)` | `null` | no |
| <a name="input_source_tags"></a> [source\_tags](#input\_source\_tags) | Source Network Tags to match (ingress only) | `list(string)` | `null` | no |
| <a name="input_target_service_accounts"></a> [target\_service\_accounts](#input\_target\_service\_accounts) | Service Accounts to apply this rule to | `list(string)` | `null` | no |
| <a name="input_target_tags"></a> [target\_tags](#input\_target\_tags) | Network Tags to apply this rule to | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_creation_timestamp"></a> [creation\_timestamp](#output\_creation\_timestamp) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
<!-- END_TF_DOCS -->