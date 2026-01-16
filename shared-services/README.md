<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc-network"></a> [vpc-network](#module\_vpc-network) | ../modules/vpc-network | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attached_projects"></a> [attached\_projects](#input\_attached\_projects) | n/a | `list(string)` | `[]` | no |
| <a name="input_cloud_nat_log_type"></a> [cloud\_nat\_log\_type](#input\_cloud\_nat\_log\_type) | n/a | `string` | `"errors"` | no |
| <a name="input_cloud_nat_max_ports_per_vm"></a> [cloud\_nat\_max\_ports\_per\_vm](#input\_cloud\_nat\_max\_ports\_per\_vm) | n/a | `number` | `4096` | no |
| <a name="input_cloud_nat_min_ports_per_vm"></a> [cloud\_nat\_min\_ports\_per\_vm](#input\_cloud\_nat\_min\_ports\_per\_vm) | n/a | `number` | `128` | no |
| <a name="input_cloud_nat_num_static_ips"></a> [cloud\_nat\_num\_static\_ips](#input\_cloud\_nat\_num\_static\_ips) | n/a | `number` | `1` | no |
| <a name="input_cloud_router_bgp_asn"></a> [cloud\_router\_bgp\_asn](#input\_cloud\_router\_bgp\_asn) | n/a | `string` | `64512` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_create_proxy_only_subnets"></a> [create\_proxy\_only\_subnets](#input\_create\_proxy\_only\_subnets) | n/a | `bool` | `true` | no |
| <a name="input_enable_netapp"></a> [enable\_netapp](#input\_enable\_netapp) | Enable PSA Connection to GCNV | `bool` | `false` | no |
| <a name="input_enable_private_access"></a> [enable\_private\_access](#input\_enable\_private\_access) | Enable Google Private Access on all Subnets | `bool` | `false` | no |
| <a name="input_enable_service_networking"></a> [enable\_service\_networking](#input\_enable\_service\_networking) | Enable PSA Connection to Service Networking | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | n/a | <pre>list(object({<br/>    name                    = optional(string)<br/>    description             = optional(string)<br/>    priority                = optional(number)<br/>    logging                 = optional(bool)<br/>    direction               = optional(string)<br/>    ranges                  = optional(list(string))<br/>    range                   = optional(string)<br/>    source_ranges           = optional(list(string))<br/>    destination_ranges      = optional(list(string))<br/>    range_types             = optional(list(string))<br/>    range_type              = optional(string)<br/>    protocol                = optional(string)<br/>    protocols               = optional(list(string))<br/>    port                    = optional(number)<br/>    ports                   = optional(list(number))<br/>    source_tags             = optional(list(string))<br/>    source_service_accounts = optional(list(string))<br/>    target_tags             = optional(list(string))<br/>    target_service_accounts = optional(list(string))<br/>    action                  = optional(string)<br/>    allow = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    deny = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    enforcement = optional(bool)<br/>    disabled    = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_gke_services_range_length"></a> [gke\_services\_range\_length](#input\_gke\_services\_range\_length) | n/a | `number` | `22` | no |
| <a name="input_internal_ips"></a> [internal\_ips](#input\_internal\_ips) | n/a | `list(string)` | <pre>[<br/>  "10.0.0.0/8",<br/>  "172.16.0.0/12",<br/>  "192.168.0.0/16",<br/>  "100.64.0.0/10"<br/>]</pre> | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | IP MTU | `number` | `null` | no |
| <a name="input_netapp_cidr"></a> [netapp\_cidr](#input\_netapp\_cidr) | n/a | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of VPC Network | `string` | n/a | yes |
| <a name="input_num_psc_subnets"></a> [num\_psc\_subnets](#input\_num\_psc\_subnets) | n/a | `number` | `16` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_proxy_only_purpose"></a> [proxy\_only\_purpose](#input\_proxy\_only\_purpose) | n/a | `string` | `"REGIONAL_MANAGED_PROXY"` | no |
| <a name="input_psc_prefix_base"></a> [psc\_prefix\_base](#input\_psc\_prefix\_base) | n/a | `string` | `null` | no |
| <a name="input_psc_purpose"></a> [psc\_purpose](#input\_psc\_purpose) | n/a | `string` | `"PRIVATE_SERVICE_CONNECT"` | no |
| <a name="input_psc_subnet_length"></a> [psc\_subnet\_length](#input\_psc\_subnet\_length) | n/a | `number` | `28` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | GCP Region Name | <pre>list(object({<br/>    region                 = string<br/>    main_cidr              = string<br/>    proxy_only_cidr        = optional(string)<br/>    subnet_name            = optional(string)<br/>    proxy_only_subnet_name = optional(string)<br/>    gke_pods_cidr          = optional(string)<br/>    gke_services_cidr      = optional(string)<br/>    attached_projects      = optional(list(string), [])<br/>    shared_accounts        = optional(list(string), [])<br/>    viewer_accounts        = optional(list(string), [])<br/>    cloud_router_name      = optional(string)<br/>    cloud_nat_name         = optional(string)<br/>    vpn_gateway_name       = optional(string)<br/>    cloud_router_bgp_asn   = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_servicenetworking_cidr"></a> [servicenetworking\_cidr](#input\_servicenetworking\_cidr) | n/a | `string` | `null` | no |
| <a name="input_shared_accounts"></a> [shared\_accounts](#input\_shared\_accounts) | n/a | `list(string)` | `[]` | no |
| <a name="input_viewer_accounts"></a> [viewer\_accounts](#input\_viewer\_accounts) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_nats"></a> [cloud\_nats](#output\_cloud\_nats) | n/a |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | n/a |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | n/a |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | n/a |
| <a name="output_peering_connections"></a> [peering\_connections](#output\_peering\_connections) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
<!-- END_TF_DOCS -->