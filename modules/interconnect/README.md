# Interconnect Attachments

## Modules Used

- [hybrid-networking](../modules/hybrid-networking)

## Input Variables

| Name                 | Description                        | Type             | Default  |
|----------------------|------------------------------------|------------------|----------|
| project_id           | Project ID of the GCP project      | `string`         | n/a      |
| region               | GCP Region Name                    | `string`         | n/a      |
| cloud_router         | Name of the Cloud Router           | `string`         | n/a      |
| type                 | Type of Interconnect               | `string`         | PARTNER  |
| name_prefix          | Name Prefix for Attachments        | `string`         | null     |
| mtu                  | IP Mtu Value                       | `number`         | 1440     |
| peer_bgp_asn         | Peer BGP AS Number                 | `number`         | 16550    |
| attachments          | List of Interconnect Attachments   | `list(object)`   | []       |
| advertised_priority  | Advertised Route Priority          | `number`         | 100      |
| advertised_ip_ranges | List of IP Ranges to Advertise     | `list(string)`   | []       |

###

`var.attachments` is a list of objects.  Attributes are below

| Name                 | Description                                                | Type           | Default |
|----------------------|------------------------------------------------------------|----------------|---------|
| name                 | Attachment Name                                            | `string`       | null    |
| description          | Attachment Description                                     | `string`       | null    |
| mtu                  | IP Mtu Value for this specific attachment                  | `number`       | null    |
| peer_bgp_asn         | Peer BGP AS Number for this specific attachment            | `number`       | null    |
| advertised_priority  | Advertised Route Priority on this specific attachment      | `number`       | null    |
| advertised_ip_ranges | List of IP Ranges to Advertise on this specific attachment | `list(string)` | null    |


## Examples

```terraform
project_id          = "my-project"
name_prefix         = "my-interconnect"
type                = "PARTNER"
region              = "us-east4"
cloud_router        = "my-router-east4"
mtu                 = 1500
advertised_priority = 0
peer_bgp_asn        = 4202000000
attachments = [
  {
    name            = "attach-0"
    cloud_router_ip = "169.254.94.97/29"
    peer_bgp_ip     = "169.254.94.98"
  },
  {
    name            = "attach-1"
    cloud_router_ip = "169.254.111.241/29"
    peer_bgp_ip     = "169.254.111.242"
  },
]
```

## Outputs

`interconnect` - Object.  Attributes are below

-   region = Region for the Interconnect
-    cloud_router = Cloud Router Name used for the Interconnect
-    attachments  = List of Interconnect Attachments


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_interconnect"></a> [interconnect](#module\_interconnect) | ../hybrid-networking | n/a |

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