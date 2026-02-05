<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16.0, < 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_interconnect_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_interconnect_attachment) | resource |
| [google_compute_router_interface.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advertised_ip_ranges"></a> [advertised\_ip\_ranges](#input\_advertised\_ip\_ranges) | n/a | `list(string)` | `[]` | no |
| <a name="input_advertised_route_priority"></a> [advertised\_route\_priority](#input\_advertised\_route\_priority) | n/a | `number` | `100` | no |
| <a name="input_attachments"></a> [attachments](#input\_attachments) | n/a | <pre>list(object({<br/>    create                    = optional(bool, true)<br/>    name                      = optional(string)<br/>    description               = optional(string)<br/>    mtu                       = optional(number)<br/>    interface_index           = optional(number)<br/>    interface_name            = optional(string)<br/>    ip_range                  = optional(string) # IP and prefix to use on GCP Cloud Router side<br/>    peer_ip_address           = optional(string) # IP address of BGP peer<br/>    peer_name                 = optional(string) # Name of BGP Peer<br/>    peer_asn                  = optional(number)<br/>    advertised_route_priority = optional(number)<br/>    advertised_groups         = optional(list(string))<br/>    advertised_ip_ranges      = optional(list(string))<br/>    ipsec_internal_addresses  = optional(list(string))<br/>    bfd                       = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_bfd"></a> [bfd](#input\_bfd) | Enable BFD | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | n/a | `string` | `"NONE"` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | If using Shared VPC, the Project ID that hosts the VPC network | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | If using Shared VPC, the Project ID that hosts the VPC network | `string` | `null` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | Default MTU for all attachments | `number` | `1440` | no |
| <a name="input_peer_asn"></a> [peer\_asn](#input\_peer\_asn) | BGP AS Number of On-Prem Router | `number` | `16550` | no |
| <a name="input_project"></a> [project](#input\_project) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Name of the GCP Region | `string` | n/a | yes |
| <a name="input_router"></a> [router](#input\_router) | Name of the Cloud Router | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | n/a | `string` | `"PARTNER"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interconnect"></a> [interconnect](#output\_interconnect) | n/a |
<!-- END_TF_DOCS -->