<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns-policy"></a> [dns-policy](#module\_dns-policy) | ../modules/dns-policy | n/a |
| <a name="module_psc-endpoints"></a> [psc-endpoints](#module\_psc-endpoints) | ../modules/forwarding-rule | n/a |
| <a name="module_vpc-network"></a> [vpc-network](#module\_vpc-network) | ../modules/vpc-network | n/a |
| <a name="module_vpns"></a> [vpns](#module\_vpns) | ../modules/hybrid-networking | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_router_bgp_asn"></a> [cloud\_router\_bgp\_asn](#input\_cloud\_router\_bgp\_asn) | n/a | `string` | `64512` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | IP MTU | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Network Name | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of VPC Network | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_psc_endpoints"></a> [psc\_endpoints](#input\_psc\_endpoints) | n/a | <pre>list(object({<br/>    project_id             = optional(string)<br/>    name                   = optional(string)<br/>    description            = optional(string)<br/>    subnet                 = optional(string)<br/>    ip_address             = optional(string)<br/>    ip_address_name        = optional(string)<br/>    ip_address_description = optional(string)<br/>    target                 = string<br/>  }))</pre> | `[]` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | n/a | `list(string)` | <pre>[<br/>  "us-central1"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | n/a |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | n/a |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | n/a |
| <a name="output_peering_connections"></a> [peering\_connections](#output\_peering\_connections) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_vpns"></a> [vpns](#output\_vpns) | n/a |
<!-- END_TF_DOCS -->