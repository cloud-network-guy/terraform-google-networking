<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.17.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns-policy"></a> [dns-policy](#module\_dns-policy) | ../modules/dns-policy | n/a |
| <a name="module_dns-zone"></a> [dns-zone](#module\_dns-zone) | ../modules/dns-zone | n/a |
| <a name="module_psc-consumers"></a> [psc-consumers](#module\_psc-consumers) | ../modules/forwarding-rule | n/a |
| <a name="module_vpc-network"></a> [vpc-network](#module\_vpc-network) | ../modules/vpc-network | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_external_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway) | resource |
| [google_compute_ha_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway) | resource |
| [google_compute_interconnect_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_interconnect_attachment) | resource |
| [google_compute_router_interface.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_service_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |
| [google_compute_vpn_tunnel.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [null_resource.dns_zone](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.peer_vpn_gateways](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.router_ip_ranges](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vpn_tunnels](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_integer.tunnel_ranges](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_string.ike_psks](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_router_bgp_asn"></a> [cloud\_router\_bgp\_asn](#input\_cloud\_router\_bgp\_asn) | BGP ASN to use for Cloud Routers on our side | `string` | `64512` | no |
| <a name="input_create"></a> [create](#input\_create) | Create resources? | `bool` | `true` | no |
| <a name="input_create_cloud_vpn_gateways"></a> [create\_cloud\_vpn\_gateways](#input\_create\_cloud\_vpn\_gateways) | Whether to create VPN gateways on GCP end | `bool` | `null` | no |
| <a name="input_create_peering_to_network_project"></a> [create\_peering\_to\_network\_project](#input\_create\_peering\_to\_network\_project) | Whether to create a VPC network peering connection to DMZ network in core network project | `bool` | `true` | no |
| <a name="input_dns_zones"></a> [dns\_zones](#input\_dns\_zones) | List of DNS zones | <pre>map(object({<br/>    create          = optional(bool, true)<br/>    project_id      = optional(string)<br/>    host_project_id = optional(string)<br/>    host_project    = optional(string)<br/>    key             = optional(string)<br/>    dns_name        = string<br/>    name            = optional(string)<br/>    description     = optional(string)<br/>    visibility      = optional(string)<br/>    networks        = optional(list(string))<br/>    peer_project    = optional(string)<br/>    peer_network    = optional(string)<br/>    logging         = optional(bool)<br/>    force_destroy   = optional(bool)<br/>    target_name_servers = optional(list(object({<br/>      ipv4_address    = string<br/>      forwarding_path = optional(string, "default")<br/>    })))<br/>    records = optional(list(object({<br/>      create  = optional(bool, true)<br/>      key     = optional(string)<br/>      name    = string<br/>      type    = optional(string)<br/>      ttl     = optional(number)<br/>      rrdatas = list(string)<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | n/a | yes |
| <a name="input_interconnect_mtu"></a> [interconnect\_mtu](#input\_interconnect\_mtu) | Default MTU Value for Interconnects | `number` | `1440` | no |
| <a name="input_internal_ip_addresses"></a> [internal\_ip\_addresses](#input\_internal\_ip\_addresses) | List of trusted IP ranges | `list(string)` | <pre>[<br/>  "10.0.0.0/8",<br/>  "172.16.0.0/12",<br/>  "192.168.0.0/16",<br/>  "100.64.0.0/10",<br/>  "198.18.0.0/15"<br/>]</pre> | no |
| <a name="input_network_project"></a> [network\_project](#input\_network\_project) | Project ID of the shared DMZ network | `string` | `null` | no |
| <a name="input_peer_bgp_asn"></a> [peer\_bgp\_asn](#input\_peer\_bgp\_asn) | BGP ASN to use for remote side | `string` | `65000` | no |
| <a name="input_peer_vpn_gateways"></a> [peer\_vpn\_gateways](#input\_peer\_vpn\_gateways) | External / Peer VPN Gateways used by Customer | <pre>map(object({<br/>    description = optional(string)<br/>    bgp_asn     = optional(number, 65000)<br/>    create      = optional(bool, true)<br/>    interfaces = list(object({<br/>      ip_address  = string<br/>      description = optional(string)<br/>      bgp_asn     = optional(number)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | GCP Project ID | `string` | n/a | yes |
| <a name="input_proxy_only_subnetwork_name"></a> [proxy\_only\_subnetwork\_name](#input\_proxy\_only\_subnetwork\_name) | n/a | `string` | `"proxy-only-subnet"` | no |
| <a name="input_psc_consumer_subnetwork_name"></a> [psc\_consumer\_subnetwork\_name](#input\_psc\_consumer\_subnetwork\_name) | n/a | `string` | `"psc-consumers"` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | List of Regions to deploy Connectivity | <pre>map(object({<br/>    cloud_router_bgp_asn = optional(number)<br/>    psc_consumers_cidr   = optional(string)<br/>    proxy_only_cidr      = optional(string)<br/>    dns_domain           = optional(string)<br/>    dns_hostname         = optional(string)<br/>    dns_aliases          = optional(list(string), [])<br/>    psc_consumers = optional(list(object({<br/>      target_service = string<br/>      nat_subnet     = string<br/>      name           = optional(string)<br/>      description    = optional(string)<br/>      create         = optional(bool, true)<br/>    })), [])<br/>    vpns = optional(list(object({<br/>      create                             = optional(bool, true)<br/>      name                               = string<br/>      description                        = optional(string)<br/>      peer_bgp_asn                       = optional(number)<br/>      peer_vpn_gateway                   = string<br/>      advertised_route_priority          = optional(number)<br/>      custom_learned_route_priority      = optional(number)<br/>      tunnel_advertised_route_priorities = optional(list(number))<br/>      tunnel_ike_psk                     = optional(list(string))<br/>      tunnel_ip_ranges                   = optional(list(string))<br/>    })), [])<br/>    interconnects = optional(list(object({<br/>      create                        = optional(bool, true)<br/>      description                   = optional(string)<br/>      mtu                           = optional(number)<br/>      peer_bgp_asn                  = optional(number)<br/>      advertised_route_priority     = optional(number)<br/>      custom_learned_route_priority = optional(number)<br/>      advertised_route_priorities   = optional(list(number))<br/>      attachment_names              = optional(list(string))<br/>      peer_names                    = optional(list(string))<br/>      interface_names               = optional(list(string))<br/>      ip_ranges                     = optional(list(string))<br/>      peer_ip_addresses             = optional(list(string))<br/>    })), [])<br/>    advertised_ip_ranges = optional(<br/>      list(object({<br/>        range       = string<br/>        description = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_set_null_subnetwork_for_psc_consumers"></a> [set\_null\_subnetwork\_for\_psc\_consumers](#input\_set\_null\_subnetwork\_for\_psc\_consumers) | Leave subnetwork field empty when creating PSC consumer forwarding rules | `bool` | `false` | no |
| <a name="input_vpn_ike_psk_length"></a> [vpn\_ike\_psk\_length](#input\_vpn\_ike\_psk\_length) | Length of IKE pre-shared keys | `number` | `20` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_vpn_gateways"></a> [cloud\_vpn\_gateways](#output\_cloud\_vpn\_gateways) | n/a |
| <a name="output_peer_vpn_gateways"></a> [peer\_vpn\_gateways](#output\_peer\_vpn\_gateways) | n/a |
| <a name="output_regions"></a> [regions](#output\_regions) | n/a |
| <a name="output_router_interfaces"></a> [router\_interfaces](#output\_router\_interfaces) | n/a |
| <a name="output_router_peers"></a> [router\_peers](#output\_router\_peers) | n/a |
| <a name="output_tunnel_ranges"></a> [tunnel\_ranges](#output\_tunnel\_ranges) | n/a |
| <a name="output_vpn_tunnels"></a> [vpn\_tunnels](#output\_vpn\_tunnels) | n/a |
<!-- END_TF_DOCS -->