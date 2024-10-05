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

