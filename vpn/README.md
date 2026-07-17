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
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_router-peers"></a> [router-peers](#module\_router-peers) | ../modules/router-peer | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_external_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway) | resource |
| [google_compute_vpn_tunnel.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [null_resource.peer_vpn_gateways](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vpn_tunnels](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [google_compute_ha_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_ha_vpn_gateway) | data source |
| [google_compute_router.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_router) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advertised_ip_ranges"></a> [advertised\_ip\_ranges](#input\_advertised\_ip\_ranges) | n/a | `list(string)` | `[]` | no |
| <a name="input_advertised_route_priority"></a> [advertised\_route\_priority](#input\_advertised\_route\_priority) | Default Priority (BGP MED) to advertise | `number` | `null` | no |
| <a name="input_bfd"></a> [bfd](#input\_bfd) | Enable BFD for all BGP Sessions | `bool` | `false` | no |
| <a name="input_cloud_vpn_gateway"></a> [cloud\_vpn\_gateway](#input\_cloud\_vpn\_gateway) | Name of the Cloud VPN Gateway | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_network"></a> [network](#input\_network) | Name of the VPC Network (can be used to find router) | `string` | `null` | no |
| <a name="input_peer_bgp_asn"></a> [peer\_bgp\_asn](#input\_peer\_bgp\_asn) | Default BGP ASN number for all Peer (External) VPN Gateways | `number` | `65000` | no |
| <a name="input_peer_vpn_gateways"></a> [peer\_vpn\_gateways](#input\_peer\_vpn\_gateways) | External / Peer VPN Gateways | <pre>map(object({<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    bgp_asn     = optional(number, 65000)<br/>    create      = optional(bool, true)<br/>    interfaces = list(object({<br/>      ip_address  = string<br/>      description = optional(string)<br/>      bgp_asn     = optional(number)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Name of the GCP Region | `string` | `null` | no |
| <a name="input_router"></a> [router](#input\_router) | Name of the Cloud Router | `string` | `null` | no |
| <a name="input_vpns"></a> [vpns](#input\_vpns) | HA VPNs | <pre>map(object({<br/>    create                       = optional(bool, true)<br/>    project                      = optional(string)<br/>    project_id                   = optional(string)<br/>    name                         = optional(string)<br/>    description                  = optional(string)<br/>    ike_version                  = optional(number)<br/>    region                       = optional(string)<br/>    router                       = optional(string)<br/>    cloud_vpn_gateway            = optional(string)<br/>    peer_vpn_gateway             = optional(string)<br/>    peer_gcp_vpn_gateway_project = optional(string)<br/>    peer_gcp_vpn_gateway         = optional(string)<br/>    peer_bgp_asn                 = optional(number)<br/>    advertised_route_priority    = optional(number)<br/>    advertised_groups            = optional(list(string))<br/>    advertised_prefixes          = optional(list(string))<br/>    advertised_ip_ranges = optional(list(object({<br/>      range       = string<br/>      description = optional(string)<br/>    })), [])<br/>    custom_learned_ip_ranges = optional(list(object({<br/>      range = string<br/>    })), [])<br/>    enable_bfd     = optional(bool)<br/>    bfd_multiplier = optional(number)<br/>    tunnels = list(object({<br/>      create                    = optional(bool)<br/>      name                      = optional(string)<br/>      description               = optional(string)<br/>      tunnel_name               = optional(string)<br/>      interface_name            = optional(string)<br/>      interface_index           = optional(number)<br/>      shared_secret             = optional(string)<br/>      ip_range                  = optional(string)<br/>      cloud_router_ip           = optional(string)<br/>      peer_bgp_name             = optional(string)<br/>      peer_bgp_ip               = optional(string)<br/>      peer_bgp_asn              = optional(number)<br/>      peer_interface_index      = optional(number)<br/>      advertised_route_priority = optional(number)<br/>      advertised_groups         = optional(list(string))<br/>      advertised_ip_ranges = optional(list(object({<br/>        range       = string<br/>        description = optional(string)<br/>      })), [])<br/>      custom_learned_ip_ranges = optional(list(object({<br/>        range = string<br/>      })), [])<br/>      enable      = optional(bool)<br/>      enable_bfd  = optional(bool)<br/>      enable_ipv6 = optional(bool)<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_tunnels"></a> [vpn\_tunnels](#output\_vpn\_tunnels) | n/a |
<!-- END_TF_DOCS -->