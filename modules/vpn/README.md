<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpns"></a> [vpns](#module\_vpns) | ../modules/hybrid-networking | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.tunnel_range](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_string.shared_secrets](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_router.cloud_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_router) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_router"></a> [cloud\_router](#input\_cloud\_router) | Name of the Cloud Router | `string` | `null` | no |
| <a name="input_cloud_vpn_gateway"></a> [cloud\_vpn\_gateway](#input\_cloud\_vpn\_gateway) | Name of the Cloud VPN Gateway | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Name of the Network attached to Cloud VPN Gateway & Cloud Router | `string` | `"default"` | no |
| <a name="input_peer_set"></a> [peer\_set](#input\_peer\_set) | Settings for External (Peer) VPN Gateways | <pre>object({<br/>    name                 = string<br/>    description          = optional(string)<br/>    bgp_asn              = optional(number, 65000)<br/>    advertised_ip_ranges = optional(list(string), [])<br/>    advertised_priority  = optional(number, 100)<br/>    peers = list(object({<br/>      name                = string<br/>      description         = optional(string)<br/>      ip_address          = string<br/>      shared_secret       = optional(string)<br/>      advertised_priority = optional(number)<br/>      cloud_router_ip     = optional(string)<br/>      peer_bgp_ip         = optional(string)<br/>      interface_index     = optional(number)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID of GCP Project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Name of the GCP Region | `string` | n/a | yes |
| <a name="input_tunnel_range"></a> [tunnel\_range](#input\_tunnel\_range) | IP Prefix to use for tunnel interfaces (i.e. 169.254.42.80/28) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_tunnels"></a> [vpn\_tunnels](#output\_vpn\_tunnels) | n/a |
<!-- END_TF_DOCS -->