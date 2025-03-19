<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud-vpn-gateway"></a> [cloud-vpn-gateway](#module\_cloud-vpn-gateway) | ../modules/hybrid-networking | n/a |
| <a name="module_psc-endpoints"></a> [psc-endpoints](#module\_psc-endpoints) | ../modules/forwarding-rule | n/a |
| <a name="module_shared-vpc"></a> [shared-vpc](#module\_shared-vpc) | ../modules/shared-vpc | n/a |
| <a name="module_vpc-network"></a> [vpc-network](#module\_vpc-network) | ../modules/vpc-network | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_shared_vpc_host_project.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_host_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attached_projects"></a> [attached\_projects](#input\_attached\_projects) | n/a | `list(string)` | `[]` | no |
| <a name="input_auto_create_subnetworks"></a> [auto\_create\_subnetworks](#input\_auto\_create\_subnetworks) | n/a | `bool` | `false` | no |
| <a name="input_cloud_nat_log_type"></a> [cloud\_nat\_log\_type](#input\_cloud\_nat\_log\_type) | Type of logging to do for Cloud NAT | `string` | `"error"` | no |
| <a name="input_cloud_nat_max_ports_per_vm"></a> [cloud\_nat\_max\_ports\_per\_vm](#input\_cloud\_nat\_max\_ports\_per\_vm) | Max number of ports to for Cloud NAT to allocate for each VM | `number` | `65536` | no |
| <a name="input_cloud_nat_min_ports_per_vm"></a> [cloud\_nat\_min\_ports\_per\_vm](#input\_cloud\_nat\_min\_ports\_per\_vm) | Min number of ports to for Cloud NAT to allocate for each VM | `number` | `32` | no |
| <a name="input_cloud_nat_name_prefix"></a> [cloud\_nat\_name\_prefix](#input\_cloud\_nat\_name\_prefix) | Name Prefix to Apply to Cloud NATs | `string` | `null` | no |
| <a name="input_cloud_nat_use_static_ip"></a> [cloud\_nat\_use\_static\_ip](#input\_cloud\_nat\_use\_static\_ip) | Allocate and use a Static IP for each Cloud NAT | `bool` | `false` | no |
| <a name="input_cloud_router_bgp_asn"></a> [cloud\_router\_bgp\_asn](#input\_cloud\_router\_bgp\_asn) | BGP AS Number for Cloud Routers (can be overridden at object level) | `number` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create this network or not | `bool` | `true` | no |
| <a name="input_create_cloud_nats"></a> [create\_cloud\_nats](#input\_create\_cloud\_nats) | Create Cloud NAT for every region | `bool` | `false` | no |
| <a name="input_create_cloud_routers"></a> [create\_cloud\_routers](#input\_create\_cloud\_routers) | Create Cloud Router for every region | `bool` | `false` | no |
| <a name="input_create_cloud_vpn_gateways"></a> [create\_cloud\_vpn\_gateways](#input\_create\_cloud\_vpn\_gateways) | Create Cloud VPN Gateway for every region | `bool` | `false` | no |
| <a name="input_create_lb_subnets"></a> [create\_lb\_subnets](#input\_create\_lb\_subnets) | Create Internal Load Balancer (proxy-only) subnets for each region | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of VPC Network | `string` | `null` | no |
| <a name="input_enable_global_routing"></a> [enable\_global\_routing](#input\_enable\_global\_routing) | Enable Global Routing (default is Regional) | `bool` | `false` | no |
| <a name="input_enable_shared_vpc_host_project"></a> [enable\_shared\_vpc\_host\_project](#input\_enable\_shared\_vpc\_host\_project) | Enable Shared VPC Host Project | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | n/a | <pre>list(object({<br/>    create                  = optional(bool, true)<br/>    project_id              = optional(string)<br/>    name                    = optional(string)<br/>    name_prefix             = optional(string)<br/>    short_name              = optional(string)<br/>    description             = optional(string)<br/>    network                 = optional(string)<br/>    network_name            = optional(string)<br/>    priority                = optional(number)<br/>    logging                 = optional(bool)<br/>    direction               = optional(string)<br/>    ranges                  = optional(list(string))<br/>    range                   = optional(string)<br/>    source_ranges           = optional(list(string))<br/>    destination_ranges      = optional(list(string))<br/>    range_types             = optional(list(string))<br/>    range_type              = optional(string)<br/>    protocol                = optional(string)<br/>    protocols               = optional(list(string))<br/>    port                    = optional(number)<br/>    ports                   = optional(list(number))<br/>    source_tags             = optional(list(string))<br/>    source_service_accounts = optional(list(string))<br/>    target_tags             = optional(list(string))<br/>    target_service_accounts = optional(list(string))<br/>    action                  = optional(string)<br/>    allow = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    deny = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    enforcement = optional(bool)<br/>    disabled    = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_ranges"></a> [ip\_ranges](#input\_ip\_ranges) | n/a | <pre>list(object({<br/>    create      = optional(bool, true)<br/>    project_id  = optional(string)<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    ip_range    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_lb_subnet_suffix"></a> [lb\_subnet\_suffix](#input\_lb\_subnet\_suffix) | Suffix to apply to LB subnets | `string` | `"ilb"` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | MTU for the VPC network: 1460 (default) or 1500 | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of VPC Network | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name Prefix to apply to all components of this VPC network | `string` | `null` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP Org ID | `string` | `null` | no |
| <a name="input_peerings"></a> [peerings](#input\_peerings) | n/a | <pre>list(object({<br/>    create                              = optional(bool, true)<br/>    project_id                          = optional(string)<br/>    name                                = optional(string)<br/>    peer_project_id                     = optional(string)<br/>    peer_network_name                   = optional(string)<br/>    peer_network_link                   = optional(string)<br/>    import_custom_routes                = optional(bool)<br/>    export_custom_routes                = optional(bool)<br/>    import_subnet_routes_with_public_ip = optional(bool)<br/>    export_subnet_routes_with_public_ip = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_regions"></a> [regions](#input\_regions) | n/a | <pre>map(object({<br/>    create_cloud_router      = optional(bool)<br/>    create_cloud_nat         = optional(bool)<br/>    create_lb_subnet         = optional(bool)<br/>    create_cloud_vpn_gateway = optional(bool)<br/>    lb_subnet_suffix         = optional(string)<br/>    lb_subnet_name           = optional(string)<br/>    lb_subnet_ip_range       = optional(string)<br/>    subnets = optional(list(object({<br/>      create                   = optional(bool, true)<br/>      project_id               = optional(string)<br/>      name                     = optional(string)<br/>      description              = optional(string)<br/>      stack_type               = optional(string)<br/>      ip_range                 = string<br/>      purpose                  = optional(string)<br/>      role                     = optional(string)<br/>      private_access           = optional(bool)<br/>      flow_logs                = optional(bool)<br/>      log_aggregation_interval = optional(string)<br/>      log_sampling_rate        = optional(number)<br/>      attached_projects        = optional(list(string))<br/>      shared_accounts          = optional(list(string))<br/>      viewer_accounts          = optional(list(string))<br/>      secondary_ranges = optional(list(object({<br/>        name  = optional(string)<br/>        range = string<br/>      })))<br/>      psc_endpoints = optional(list(object({<br/>        target            = optional(string)<br/>        target_project_id = optional(string)<br/>        target_name       = optional(string)<br/>        name              = optional(string)<br/>        ip_address        = optional(string)<br/>        ip_address_name   = optional(string)<br/>        global_access     = optional(bool)<br/>      })))<br/>    })))<br/>    cloud_routers = optional(list(object({<br/>      create                        = optional(bool, true)<br/>      project_id                    = optional(string)<br/>      name                          = optional(string)<br/>      description                   = optional(string)<br/>      encrypted_interconnect_router = optional(bool)<br/>      bgp_asn                       = optional(number)<br/>      bgp_keepalive_interval        = optional(number)<br/>      advertised_groups             = optional(list(string))<br/>      advertised_ip_ranges = optional(list(object({<br/>        create      = optional(bool)<br/>        range       = string<br/>        description = optional(string)<br/>      })))<br/>    })))<br/>    cloud_nats = optional(list(object({<br/>      create            = optional(bool, true)<br/>      project_id        = optional(string)<br/>      name              = optional(string)<br/>      cloud_router      = optional(string)<br/>      cloud_router_name = optional(string)<br/>      subnets           = optional(list(string))<br/>      num_static_ips    = optional(number)<br/>      static_ips = optional(list(object({<br/>        name        = optional(string)<br/>        description = optional(string)<br/>        address     = optional(string)<br/>      })))<br/>      log_type                     = optional(string)<br/>      enable_dpa                   = optional(bool)<br/>      min_ports_per_vm             = optional(number)<br/>      max_ports_per_vm             = optional(number)<br/>      enable_eim                   = optional(bool)<br/>      udp_idle_timeout             = optional(number)<br/>      tcp_established_idle_timeout = optional(number)<br/>      tcp_time_wait_timeout        = optional(number)<br/>      tcp_transitory_idle_timeout  = optional(number)<br/>      icmp_idle_timeout            = optional(number)<br/>    })))<br/>    vpc_access_connectors = optional(list(object({<br/>      create             = optional(bool, true)<br/>      project_id         = optional(string)<br/>      network_project_id = optional(string)<br/>      name               = optional(string)<br/>      region             = optional(string)<br/>      cidr_range         = optional(string)<br/>      subnet             = optional(string)<br/>      min_throughput     = optional(number)<br/>      max_throughput     = optional(number)<br/>      min_instances      = optional(number)<br/>      max_instances      = optional(number)<br/>      machine_type       = optional(string)<br/>    })))<br/>    cloud_vpn_gateways = optional(list(object({<br/>      create     = optional(bool, true)<br/>      project_id = optional(string)<br/>      name       = optional(string)<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | n/a | <pre>list(object({<br/>    create        = optional(bool, true)<br/>    project_id    = optional(string)<br/>    name          = optional(string)<br/>    description   = optional(string)<br/>    dest_range    = optional(string)<br/>    dest_ranges   = optional(list(string))<br/>    priority      = optional(number)<br/>    tags          = optional(list(string))<br/>    next_hop      = optional(string)<br/>    next_hop_zone = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_service_connections"></a> [service\_connections](#input\_service\_connections) | n/a | <pre>list(object({<br/>    create               = optional(bool, true)<br/>    project_id           = optional(string)<br/>    name                 = optional(string)<br/>    service              = optional(string)<br/>    ip_ranges            = list(string)<br/>    import_custom_routes = optional(bool)<br/>    export_custom_routes = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_shared_accounts"></a> [shared\_accounts](#input\_shared\_accounts) | n/a | `list(string)` | `[]` | no |
| <a name="input_subnet_private_access"></a> [subnet\_private\_access](#input\_subnet\_private\_access) | Enable Private Google Access on all subnets (can be overridden at subnet level) | `bool` | `false` | no |
| <a name="input_viewer_accounts"></a> [viewer\_accounts](#input\_viewer\_accounts) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | n/a |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | n/a |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | n/a |
| <a name="output_peering_connections"></a> [peering\_connections](#output\_peering\_connections) | n/a |
<!-- END_TF_DOCS -->