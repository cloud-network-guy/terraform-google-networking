<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.38.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_psc-endpoints"></a> [psc-endpoints](#module\_psc-endpoints) | ../modules/forwarding-rule | n/a |
| <a name="module_shared-vpc"></a> [shared-vpc](#module\_shared-vpc) | ../modules/shared-vpc | n/a |
| <a name="module_vpc-network"></a> [vpc-network](#module\_vpc-network) | ../modules/vpc-network | n/a |
| <a name="module_vpn-to-hub"></a> [vpn-to-hub](#module\_vpn-to-hub) | ../modules/hybrid-networking | n/a |
| <a name="module_vpn-to-spoke"></a> [vpn-to-spoke](#module\_vpn-to-spoke) | ../modules/hybrid-networking | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.tunnel_fourth_octet_base](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.tunnel_third_octet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_string.ike_psks](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_zones.all_zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_external_egress"></a> [allow\_external\_egress](#input\_allow\_external\_egress) | n/a | `bool` | `true` | no |
| <a name="input_allow_external_ingress"></a> [allow\_external\_ingress](#input\_allow\_external\_ingress) | n/a | `bool` | `false` | no |
| <a name="input_allow_internal_egress"></a> [allow\_internal\_egress](#input\_allow\_internal\_egress) | n/a | `bool` | `true` | no |
| <a name="input_allow_internal_ingress"></a> [allow\_internal\_ingress](#input\_allow\_internal\_ingress) | n/a | `bool` | `true` | no |
| <a name="input_attached_projects"></a> [attached\_projects](#input\_attached\_projects) | n/a | `list(string)` | `[]` | no |
| <a name="input_cloud_nat_log_type"></a> [cloud\_nat\_log\_type](#input\_cloud\_nat\_log\_type) | n/a | `string` | `"errors"` | no |
| <a name="input_cloud_nat_max_ports_per_vm"></a> [cloud\_nat\_max\_ports\_per\_vm](#input\_cloud\_nat\_max\_ports\_per\_vm) | n/a | `number` | `4096` | no |
| <a name="input_cloud_nat_min_ports_per_vm"></a> [cloud\_nat\_min\_ports\_per\_vm](#input\_cloud\_nat\_min\_ports\_per\_vm) | n/a | `number` | `128` | no |
| <a name="input_cloud_nat_num_static_ips"></a> [cloud\_nat\_num\_static\_ips](#input\_cloud\_nat\_num\_static\_ips) | n/a | `number` | `1` | no |
| <a name="input_cloud_nat_routes"></a> [cloud\_nat\_routes](#input\_cloud\_nat\_routes) | n/a | `list(string)` | `[]` | no |
| <a name="input_cloud_router_bgp_asn"></a> [cloud\_router\_bgp\_asn](#input\_cloud\_router\_bgp\_asn) | n/a | `string` | `64512` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_create_proxy_only_subnet"></a> [create\_proxy\_only\_subnet](#input\_create\_proxy\_only\_subnet) | n/a | `bool` | `true` | no |
| <a name="input_enable_netapp_cv"></a> [enable\_netapp\_cv](#input\_enable\_netapp\_cv) | Enable PSA Connection NetApp Cloud Volumes | `bool` | `false` | no |
| <a name="input_enable_netapp_gcnv"></a> [enable\_netapp\_gcnv](#input\_enable\_netapp\_gcnv) | Enable PSA Connection NetApp Cloud Volumes | `bool` | `true` | no |
| <a name="input_enable_private_access"></a> [enable\_private\_access](#input\_enable\_private\_access) | Enable Google Private Access on all Subnets | `bool` | `false` | no |
| <a name="input_enable_service_networking"></a> [enable\_service\_networking](#input\_enable\_service\_networking) | Enable PSA Connection to Service Networking | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | n/a | <pre>list(object({<br/>    name                    = optional(string)<br/>    description             = optional(string)<br/>    priority                = optional(number)<br/>    logging                 = optional(bool)<br/>    direction               = optional(string)<br/>    ranges                  = optional(list(string))<br/>    range                   = optional(string)<br/>    source_ranges           = optional(list(string))<br/>    destination_ranges      = optional(list(string))<br/>    range_types             = optional(list(string))<br/>    range_type              = optional(string)<br/>    protocol                = optional(string)<br/>    protocols               = optional(list(string))<br/>    port                    = optional(number)<br/>    ports                   = optional(list(number))<br/>    source_tags             = optional(list(string))<br/>    source_service_accounts = optional(list(string))<br/>    target_tags             = optional(list(string))<br/>    target_service_accounts = optional(list(string))<br/>    action                  = optional(string)<br/>    allow = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    deny = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    enforcement = optional(bool)<br/>    disabled    = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_gke_services_range_length"></a> [gke\_services\_range\_length](#input\_gke\_services\_range\_length) | n/a | `number` | `22` | no |
| <a name="input_hub_vpc"></a> [hub\_vpc](#input\_hub\_vpc) | n/a | <pre>object({<br/>    project_id           = optional(string)<br/>    network              = optional(string, "default")<br/>    bgp_asn              = optional(number, 64512)<br/>    cloud_router         = optional(string)<br/>    cloud_vpn_gateway    = optional(string)<br/>    advertised_ip_ranges = optional(list(string), ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])<br/>  })</pre> | n/a | yes |
| <a name="input_internal_ips"></a> [internal\_ips](#input\_internal\_ips) | n/a | `list(string)` | <pre>[<br/>  "10.0.0.0/8",<br/>  "172.16.0.0/12",<br/>  "192.168.0.0/16",<br/>  "100.64.0.0/10"<br/>]</pre> | no |
| <a name="input_log_external_egress"></a> [log\_external\_egress](#input\_log\_external\_egress) | n/a | `bool` | `true` | no |
| <a name="input_log_external_ingress"></a> [log\_external\_ingress](#input\_log\_external\_ingress) | n/a | `bool` | `true` | no |
| <a name="input_log_internal_egress"></a> [log\_internal\_egress](#input\_log\_internal\_egress) | n/a | `bool` | `false` | no |
| <a name="input_log_internal_ingress"></a> [log\_internal\_ingress](#input\_log\_internal\_ingress) | n/a | `bool` | `false` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | IP MTU | `number` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name Prefix to give to all resources | `string` | `"vpc"` | no |
| <a name="input_netapp_cidr"></a> [netapp\_cidr](#input\_netapp\_cidr) | n/a | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of VPC Network | `string` | `null` | no |
| <a name="input_num_psc_subnets"></a> [num\_psc\_subnets](#input\_num\_psc\_subnets) | n/a | `number` | `16` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_proxy_only_cidr"></a> [proxy\_only\_cidr](#input\_proxy\_only\_cidr) | n/a | `string` | `null` | no |
| <a name="input_proxy_only_purpose"></a> [proxy\_only\_purpose](#input\_proxy\_only\_purpose) | n/a | `string` | `"REGIONAL_MANAGED_PROXY"` | no |
| <a name="input_psc_endpoints"></a> [psc\_endpoints](#input\_psc\_endpoints) | n/a | <pre>list(object({<br/>    project_id             = optional(string)<br/>    name                   = optional(string)<br/>    description            = optional(string)<br/>    subnet                 = optional(string)<br/>    ip_address             = optional(string)<br/>    ip_address_name        = optional(string)<br/>    ip_address_description = optional(string)<br/>    target                 = string<br/>  }))</pre> | `[]` | no |
| <a name="input_psc_prefix_base"></a> [psc\_prefix\_base](#input\_psc\_prefix\_base) | n/a | `string` | `null` | no |
| <a name="input_psc_purpose"></a> [psc\_purpose](#input\_psc\_purpose) | n/a | `string` | `"PRIVATE_SERVICE_CONNECT"` | no |
| <a name="input_psc_subnet_length"></a> [psc\_subnet\_length](#input\_psc\_subnet\_length) | n/a | `number` | `28` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP Region Name | `string` | n/a | yes |
| <a name="input_require_regional_network_tag"></a> [require\_regional\_network\_tag](#input\_require\_regional\_network\_tag) | n/a | `bool` | `false` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | n/a | <pre>list(object({<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    priority    = optional(number)<br/>    dest_range  = optional(string)<br/>    dest_ranges = optional(list(string))<br/>    next_hop    = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_servicenetworking_cidr"></a> [servicenetworking\_cidr](#input\_servicenetworking\_cidr) | n/a | `string` | `null` | no |
| <a name="input_shared_accounts"></a> [shared\_accounts](#input\_shared\_accounts) | n/a | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | <pre>list(object({<br/>    main_cidr         = string<br/>    gke_pods_cidr     = string<br/>    gke_services_cidr = string<br/>    region            = optional(string)<br/>    name              = optional(string)<br/>    attached_projects = optional(list(string), [])<br/>    shared_accounts   = optional(list(string), [])<br/>    viewer_accounts   = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_viewer_accounts"></a> [viewer\_accounts](#input\_viewer\_accounts) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_nats"></a> [cloud\_nats](#output\_cloud\_nats) | n/a |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | n/a |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | n/a |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | n/a |
| <a name="output_peering_connections"></a> [peering\_connections](#output\_peering\_connections) | n/a |
| <a name="output_spoke_vpn_tunnels"></a> [spoke\_vpn\_tunnels](#output\_spoke\_vpn\_tunnels) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
<!-- END_TF_DOCS -->