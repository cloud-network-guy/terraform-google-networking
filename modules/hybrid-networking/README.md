# GCP Hybrid Networking

Management of Cloud Routers, Interconnects, and VPNs

## Resources 

- [google_compute_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)
- [google_compute_router_interface](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface)
- [google_compute_router_peer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer)
- [google_compute_interconnect_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_interconnect_attachment)
- [google_compute_ha_vpn_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway)
- [google_compute_external_vpn_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway)
- [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)
- [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)

## Inputs 

### Global Inputs

| Name           | Description                      | Type     | Default  |
|----------------|----------------------------------|----------|----------|
| project_id     | Project ID of the GCP project    | `string` | n/a      |
| region         | Name of the default GCP region   | `string` | n/a      |
| network_name   | Name of default VPC Network      | `string` | default  |

### Cloud Routers

The `cloud_routers` variable is a list of objects.  Attributes are below.

| Name                   | Description                         | Type      | Default            |
|------------------------|-------------------------------------|-----------|--------------------|
| name                   | Name of the Cloud Router            | `string`  | rtr-<network_name> |
| description            | Description of the Cloud Router     | `string`  | n/a                |
| project_id             | Project ID of the GCP project       | `string`  | n/a                |
| region                 | Name of the GCP region              | `string`  | n/a                |
| network_name           | Name of default VPC Network         | `string`  | default            |
| bgp_asn                | BGP AS Number for the Cloud Router  | `number`  | 64512              |
| bgp_keepalive_interval | BGP Keepalive Interval (in seconds) | `number`  | 20                 |
| create                 | Whether to create the resource      | `bool`    | true               |


#### 

The `advertised_ip_ranges` attribute is a list of objects.  Attributes are below.

| Name        | Description              | Type     | Default    |
|-------------|--------------------------|----------|------------|
| range       | IP Range to Advertise    | `string` | n/a        |
| description | Description of IP Range  | `string` | n/a        |


### Cloud VPN Gateways

The `cloud_vpn_gateways` variable is a list of objects.  Attributes are below.

| Name                   | Description                    | Type     | Default            |
|------------------------|--------------------------------|----------|--------------------|
| name                   | Name of the Cloud VPN Gateway  | `string` | rtr-<network_name> |
| region                 | Name of the GCP region         | `string` | n/a                |
| project_id             | Project ID of the GCP project  | `string` | n/a                |
| network_name           | Name of attached VPC Network   | `string` | default            |
| create                 | Whether to create the resource | `bool`   | true               |

### Peer (External) VPN Gateways

The `peer_vpn_gateways` variable is a list of objects.  Attributes are below.

| Name         | Description                             | Type            | Default              |
|--------------|-----------------------------------------|-----------------|----------------------|
| name         | Name of the Peer (External) VPN Gateway | `string`        | vpngw-<network_name> |
| description  | Description of the VPN Gateway          | `string`        | n/a                  |
| project_id   | Project ID of the GCP project           | `string`        | n/a                  |
| ip_addresses | IP Addresses for the Peer VPN Gateway   | `list(string)`  | n/a                  |
| labels       | Labels for the Peer VPN Gateway         | `map(string)`   | n/a                  |
| create       | Whether to create the resource          | `bool`          | true                 |


### VPN Tunnels

The `vpns` variable is a list of objects.  Attributes are below.

| Name                              | Description                                             | Type           | Default            |
|-----------------------------------|---------------------------------------------------------|----------------|--------------------|
| name                              | Name of the Peer (External) VPN Gateway                 | `string`       | vpn-<network_name> |
| description                       | Description of the VPN Gateway                          | `string`       | n/a                |
| project_id                        | Project ID of the GCP project                           | `string`       | n/a                |
| region                            | Name of the GCP region                                  | `string`       | n/a                |
| cloud_router                      | Name of the Cloud Router                                | `string`       | n/a                |
| cloud_vpn_gateway                 | Name of the Cloud VPN Gateway                           | `string`       | n/a                |
| peer_vpn_gateway                  | Name of the Peer VPN Gateway                            | `string`       | n/a                |
| peer_gcp_vpn_gateway_project_id   | For GCP VPN Peers, project ID of peer VPN Gatewaay      | `string`       | n/a                |
| peer_gcp_vpn_gateway              | For GCP VPN Peers, Name of the of peer VPN Gateway      | `string`       | n/a                |
| peer_bgp_asn                      | BGP AS Number for the Peer                              | `number`       | 65000              |
| advertised_priority               | Priority (BGP MED) for advertised routes                | `number`       | 100                |
| advertised_groups                 | Types of Groups to Advertise via BGP                    | `list(string)` | n/a                |
| tunnels | 

### VPN Tunnels

The `tunnels` attribute is a list of objects.  Attributes are below.

| Name                | Description                              | Type        | Default  |
|---------------------|------------------------------------------|-------------|----------|
| name                | Name of the VPN Tunnel                   | `string`    | n/a      |
| ike_version         | IKE version to use                       | `number`    | 2        |
| ike_psk             | Pre-shared Secret for IKE                | `string`    | n/a      |
| cloud_router_ip     | IP Address for the GCP end               | `string`    | n/a      |
| peer_bgp_ip         | IP address for the remote peer           | `string`    | n/a      |
| peer_bgp_asn        | BGP AS Number for the Peer               | `number`    | 65000    |
| advertised_priority | Priority (BGP MED) for advertised routes | `number`    | 100      |
| enable_bfd          | Enable the BFD failure detection         | `bool`      | false    |
| enable              | Enable the BGP session                   | `bool`      | true     |

### Interconnects

The `interconnects` variable is a list of objects.  Attributes are below.

| Name              | Description                     | Type     | Default |
|-------------------|---------------------------------|----------|---------|
| name              | Name of the Interconnect        | `string` | n/a     |
| description       | Description of the Interconnect | `string` | n/a     |
| project_id        | Project ID of the GCP project   | `string` | n/a     |
| region            | Name of the GCP region          | `string` | n/a     |
| cloud_router      | Name of the Cloud Router        | `string` | n/a     |


## Examples

### VPN Tunnels w/ Dynamic Routing

```
vpns = [
]
```

#### 2x2 VPN Tunnels from GCP to AWS

```
peer_vpn_gateways = [
  {
    name = "aws-us-east1"
    ip_addresses = [
      "3.221.123.12",    # GCP HA VPN Gateway interface 0, AWS Tunnel 1
      "52.202.123.34",   # GCP HA VPN Gateway interface 0, AWS Tunnel 2
      "18.234.123.56",   # GCP HA VPN Gateway interface 1, AWS Tunnel 1
      "52.71.123.78",    # GCP HA VPN Gateway interface 1, AWS Tunnel 2
    ]
  },
]
vpns = [
  {
    name                 = "gcp-2-aws"
    region               = "us-east4"
    cloud_router         = "my-cloud-router"
    cloud_vpn_gateway    = "my-vpn-gateway"
    peer_vpn_gateway     = "aws-us-east1"
    peer_bgp_asn         = 64512
    advertised_ip_ranges = [{ range = "10.20.30.0/23" }]
    tunnels = [
      {
        interface_index     = 0
        ike_psk             = "aaaaaaaaaaaaaa"
        cloud_router_ip     = "169.254.21.2/30"
        bgp_peer_ip         = "169.254.21.1"
        advertised_priority = 100
      },
      {
        interface_index     = 0
        ike_psk             = "bbbbbbbbbbbbbbb"
        cloud_router_ip     = "169.254.22.66/30"
        bgp_peer_ip         = "169.254.22.65"
        advertised_priority = 102
      },
      {
        interface_index     = 1
        ike_psk             = "cccccccccccccccc"
        cloud_router_ip     = "169.254.23.130/30"
        bgp_peer_ip         = "169.254.23.129"
        advertised_priority = 101
      },
      {
        interface_index     = 1
        ike_psk             = "dddddddddddddddd"
        cloud_router_ip     = "169.254.24.194/30"
        bgp_peer_ip         = "169.254.24.193"
        advertised_priority = 103
      },
    ]
  },
]
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16, < 8.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_external_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway) | resource |
| [google_compute_ha_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway) | resource |
| [google_compute_interconnect_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_interconnect_attachment) | resource |
| [google_compute_router_interface.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_vpn_tunnel.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [null_resource.peer_vpn_gateways](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vpn_tunnels](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [google_compute_ha_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_ha_vpn_gateway) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_router"></a> [cloud\_router](#input\_cloud\_router) | Default Cloud Router Name (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_cloud_vpn_gateways"></a> [cloud\_vpn\_gateways](#input\_cloud\_vpn\_gateways) | GCP Cloud VPN Gateways | <pre>list(object({<br/>    create       = optional(bool, true)<br/>    project_id   = optional(string)<br/>    name         = optional(string)<br/>    network      = optional(string)<br/>    network_name = optional(string)<br/>    region       = string<br/>    stack_type   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_defaults"></a> [defaults](#input\_defaults) | n/a | <pre>object({<br/>    cloud_router_bgp_asn                = optional(number, 64512)<br/>    cloud_router_bgp_keepalive_interval = optional(number, 20)<br/>    vpn_ike_version                     = optional(number, 2)<br/>    vpn_ike_psk_length                  = optional(number, 20)<br/>    vpn_ike_psk                         = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_interconnects"></a> [interconnects](#input\_interconnects) | Dedicated and Partner Interconnects | <pre>list(object({<br/>    create              = optional(bool, true)<br/>    project_id          = optional(string)<br/>    type                = string<br/>    name_prefix         = optional(string)<br/>    region              = optional(string)<br/>    cloud_router        = optional(string)<br/>    advertised_priority = optional(number)<br/>    advertised_groups   = optional(list(string))<br/>    advertised_ip_ranges = optional(list(object({<br/>      range       = string<br/>      description = optional(string)<br/>    })))<br/>    mtu            = optional(number)<br/>    enable         = optional(bool)<br/>    enable_bfd     = optional(bool)<br/>    bfd_parameters = optional(list(number))<br/>    attachments = list(object({<br/>      name                = optional(string)<br/>      description         = optional(string)<br/>      mtu                 = optional(number)<br/>      interface_index     = optional(number)<br/>      interface_name      = optional(string)<br/>      cloud_router_ip     = optional(string)<br/>      peer_bgp_name       = optional(string)<br/>      peer_bgp_ip         = optional(string)<br/>      peer_bgp_asn        = optional(number)<br/>      advertised_priority = optional(number)<br/>      advertised_groups   = optional(list(string))<br/>      advertised_ip_ranges = optional(list(object({<br/>        range       = string<br/>        description = optional(string)<br/>      })))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | Default VPC Network Name to attach to | `string` | `"default"` | no |
| <a name="input_peer_vpn_gateways"></a> [peer\_vpn\_gateways](#input\_peer\_vpn\_gateways) | Peer (External) VPN Gateways | <pre>list(object({<br/>    create       = optional(bool, true)<br/>    project_id   = optional(string)<br/>    name         = optional(string)<br/>    description  = optional(string)<br/>    ip_addresses = optional(list(string))<br/>    labels       = optional(map(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Default GCP Region Name (can be overridden at resource level) | `string` | `"us-central1"` | no |
| <a name="input_vpns"></a> [vpns](#input\_vpns) | HA VPNs | <pre>list(object({<br/>    create                          = optional(bool, true)<br/>    project_id                      = optional(string)<br/>    name                            = optional(string)<br/>    description                     = optional(string)<br/>    ike_version                     = optional(number)<br/>    region                          = optional(string)<br/>    cloud_router                    = optional(string)<br/>    cloud_vpn_gateway               = optional(string)<br/>    peer_vpn_gateway                = optional(string)<br/>    peer_gcp_vpn_gateway_project_id = optional(string)<br/>    peer_gcp_vpn_gateway            = optional(string)<br/>    peer_bgp_asn                    = optional(number)<br/>    advertised_priority             = optional(number)<br/>    advertised_groups               = optional(list(string))<br/>    advertised_ip_ranges = optional(list(object({<br/>      range       = string<br/>      description = optional(string)<br/>    })))<br/>    enable_bfd     = optional(bool)<br/>    bfd_multiplier = optional(number)<br/>    tunnels = list(object({<br/>      create               = optional(bool)<br/>      name                 = optional(string)<br/>      interface_index      = optional(number)<br/>      interface_name       = optional(string)<br/>      description          = optional(string)<br/>      ike_version          = optional(number)<br/>      ike_psk              = optional(string)<br/>      cloud_router_ip      = optional(string)<br/>      peer_bgp_name        = optional(string)<br/>      peer_bgp_ip          = optional(string)<br/>      peer_bgp_asn         = optional(number)<br/>      peer_interface_index = optional(number)<br/>      advertised_priority  = optional(number)<br/>      advertised_groups    = optional(list(string))<br/>      advertised_ip_ranges = optional(list(object({<br/>        range       = string<br/>        description = optional(string)<br/>      })))<br/>      enable      = optional(bool)<br/>      enable_bfd  = optional(bool)<br/>      enable_ipv6 = optional(bool)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_vpn_gateways"></a> [cloud\_vpn\_gateways](#output\_cloud\_vpn\_gateways) | n/a |
| <a name="output_interconnect_attachments"></a> [interconnect\_attachments](#output\_interconnect\_attachments) | n/a |
| <a name="output_peer_vpn_gateways"></a> [peer\_vpn\_gateways](#output\_peer\_vpn\_gateways) | n/a |
| <a name="output_vpn_tunnels"></a> [vpn\_tunnels](#output\_vpn\_tunnels) | n/a |
<!-- END_TF_DOCS -->