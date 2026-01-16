<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 8.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_interconnect"></a> [interconnect](#module\_interconnect) | ../modules/hybrid-networking | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advertised_ip_ranges"></a> [advertised\_ip\_ranges](#input\_advertised\_ip\_ranges) | n/a | `list(string)` | `[]` | no |
| <a name="input_advertised_priority"></a> [advertised\_priority](#input\_advertised\_priority) | n/a | `number` | `100` | no |
| <a name="input_attachments"></a> [attachments](#input\_attachments) | n/a | <pre>list(object({<br/>    name                     = optional(string)<br/>    description              = optional(string)<br/>    mtu                      = optional(number)<br/>    interface_index          = optional(number)<br/>    interface_name           = optional(string)<br/>    cloud_router_ip          = optional(string)<br/>    peer_bgp_ip              = optional(string)<br/>    peer_bgp_asn             = optional(string)<br/>    peer_bgp_name            = optional(string)<br/>    advertised_priority      = optional(number)<br/>    advertised_groups        = optional(list(string))<br/>    advertised_ip_ranges     = optional(list(string))<br/>    ipsec_internal_addresses = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_router"></a> [cloud\_router](#input\_cloud\_router) | Name of the Cloud Router | `string` | n/a | yes |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | n/a | `string` | `null` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | n/a | `number` | `1440` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name Prefix for the Interconnect | `string` | `null` | no |
| <a name="input_peer_bgp_asn"></a> [peer\_bgp\_asn](#input\_peer\_bgp\_asn) | n/a | `number` | `16550` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID of GCP Project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Name of the GCP Region | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `"PARTNER"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interconnect"></a> [interconnect](#output\_interconnect) | n/a |
<!-- END_TF_DOCS -->