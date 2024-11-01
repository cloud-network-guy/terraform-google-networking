# Management of GCP VPC Networks and their components:

- Subnets & IP Ranges
- Cloud Routers
- Cloud NATs
- Peering Connections
- Static Routes
- Firewall Rules
- IP Ranges
- Private Service Connects
- Shared VPC Permissions
- Serverless VPC Access Connectors

## Resources 

- [google_compute_address]
- [google_compute_firewall]
- [google_compute_global_address]
- [google_compute_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)
- [google_compute_network_peering]
- [google_compute_network_peering_routes_config]
- [google_compute_route]
- [google_compute_router]
- [google_compute_router_nat]
- [google_compute_subnetwork]
- [google_compute_subnetwork_iam_binding]
- [google_service_networking_connection]
- [google_vpc_access_connector]

## Inputs 

### Global Inputs

| Name                   | Description                      | Type           | Default |
|------------------------|----------------------------------|----------------|---------|
| project_id             | Default GCP Project ID           | `string`       | n/a     |
| region                 | Default GCP Region               | `string`       | n/a     |
| vpc_networks           | List of VPC Networks (see below) | `list(object)` | n/a     |

### vpc_networks

`var.vpc_networks` is a list of objects.  Attributes are described below

| Name                    | Description                                   | Type           | Default |
|-------------------------|-----------------------------------------------|----------------|---------|
| mtu                     | IP MTU Value                                  | `number`       | 0       |
| enable_global_routing   | Use Global Routing rather than Regional       | `bool`         | false   |
| auto_create_subnetworks | Automatically create subnets for each region  | `bool`         | false   |
| service_project_ids     | Shared VPC Service Projects list              | `list(string)` | []      |
| shared_accounts         | Specific accounts to share all subnets to     | `list(string)` | []      |
| subnets                 | List of Subnetworks (see below)               | `list(object)` | []      |
| routes                  | List of Routes (see below)                    | `list(object)` | []      |
| peerings                | List of VPC Peering Connections (see below)   | `list(object)` | []      |
| ip_ranges               | List of Private Service IP Ranges (see below) | `list(object)` | []      |
| cloud_routers           | List of Cloud Routers (see below)             | `list(object)` | []      |
| cloud_nats              | List of Cloud NATs (see below)                | `list(object)` | []      |

Example:

```terraform
vpc_networks = [
  {
    name                  = "my-vpc-1"
    enable_global_routing = true
  },
  {
    name                    = "my-vpc-2"
    auto_create_subnetworks = true
  },
]

```


#### subnets

`var.vpc_networks.subnets` is a list of objects.  Attributes are described below

| Name                | Description                                 | Type      | Default  |
|---------------------|---------------------------------------------|-----------|----------|
| name                | Subnetwork Name                             | `string`  | n/a      |
| description         | Subnetwork Description                      | `string`  | null     |
| region              | GCP Region                                  | `string`  | n/a      |
| ip_range            | Main IP Range CIDR                          | `string`  | n/a      |
| purpose             | Subnet Purpose                              | `string`  | PRIVATE  |
| role                | For Proxy-Only Subnets, the role            | `string`  | ACTIVE   |
| private_access      | Enable Private Google Access                | `bool`    | false    | 
| flow_logs           | Enable Flow Logs on this subnet             | `bool`    | false    |
| service_project_ids | Shared VPC Service Projects list            | `list(string)` | []      |
| shared_accounts     | Specific accounts to share this subnets to  | `list(string)` | []      |

Examples

```terraform
    subnets = [
      {
        name     = "subnet1"
        region   = "us-east1"
        ip_range = "172.29.1.0/24"
      }
    ]
```


#### peerings

`var.vpc_networks.peerings` is a list of objects.  Attributes are described below

| Name                                | Description                               | Type     | Default   |
|-------------------------------------|-------------------------------------------|----------|-----------|
| name                                | Peering Connection Name                   | `string` | n/a       |
| peer_project_id                     | Project ID of Peer                        | `string` | null      |
| peer_network_name                   | VPC Network Name in that project          | `string` | n/a       | 
| peer_network_link                   | Peer Self Link (projects/peer-project...) | `string` | n/a       | 
| import_custom_routes                |                                           | bool     | false     |
| export_custom_routes                |                                           | bool     | false     |
| import_subnet_routes_with_public_ip |                                           | bool     | false     | 
| export_subnet_routes_with_public_ip |                                           | bool     | false     | 

Examples

```terraform
  peerings = [
      {
        name              = "peering1"
        peer_project_id   = "other-project"
        peer_network_name = "other-network"
      }
    ]
```
## IMPORT examples


```
```



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.5, < 7.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 5.16, < 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.8.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.cloud_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_address.psa_ranges](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_peering.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering_routes_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_compute_route.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_router.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_service_networking_connection.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_vpc_access_connector.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector) | resource |
| [null_resource.network](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.subnets](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_netblock_ip_ranges.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attached_projects"></a> [attached\_projects](#input\_attached\_projects) | n/a | `list(string)` | `[]` | no |
| <a name="input_auto_create_subnetworks"></a> [auto\_create\_subnetworks](#input\_auto\_create\_subnetworks) | n/a | `bool` | `false` | no |
| <a name="input_cloud_nats"></a> [cloud\_nats](#input\_cloud\_nats) | n/a | <pre>list(object({<br/>    create         = optional(bool, true)<br/>    name           = optional(string)<br/>    region         = optional(string)<br/>    router         = optional(string)<br/>    subnets        = optional(list(string))<br/>    num_static_ips = optional(number)<br/>    static_ips = optional(list(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      address     = optional(string)<br/>    })))<br/>    log_type                     = optional(string)<br/>    enable_dpa                   = optional(bool)<br/>    min_ports_per_vm             = optional(number)<br/>    max_ports_per_vm             = optional(number)<br/>    enable_eim                   = optional(bool)<br/>    udp_idle_timeout             = optional(number)<br/>    tcp_established_idle_timeout = optional(number)<br/>    tcp_time_wait_timeout        = optional(number)<br/>    tcp_transitory_idle_timeout  = optional(number)<br/>    icmp_idle_timeout            = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_routers"></a> [cloud\_routers](#input\_cloud\_routers) | n/a | <pre>list(object({<br/>    create                        = optional(bool, true)<br/>    name                          = optional(string)<br/>    description                   = optional(string)<br/>    encrypted_interconnect_router = optional(bool)<br/>    region                        = optional(string)<br/>    enable_bgp                    = optional(bool)<br/>    bgp_asn                       = optional(number)<br/>    bgp_keepalive_interval        = optional(number)<br/>    advertised_groups             = optional(list(string))<br/>    advertised_ip_ranges = optional(list(object({<br/>      create      = optional(bool)<br/>      range       = string<br/>      description = optional(string)<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_default_region"></a> [default\_region](#input\_default\_region) | n/a | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_enable_ula_internal_ipv6"></a> [enable\_ula\_internal\_ipv6](#input\_enable\_ula\_internal\_ipv6) | n/a | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | n/a | <pre>list(object({<br/>    create                  = optional(bool, true)<br/>    network                 = optional(string)<br/>    name                    = optional(string)<br/>    description             = optional(string)<br/>    priority                = optional(number)<br/>    logging                 = optional(bool)<br/>    direction               = optional(string)<br/>    ranges                  = optional(list(string))<br/>    range                   = optional(string)<br/>    source_ranges           = optional(list(string))<br/>    destination_ranges      = optional(list(string))<br/>    range_types             = optional(list(string))<br/>    range_type              = optional(string)<br/>    protocol                = optional(string)<br/>    protocols               = optional(list(string))<br/>    port                    = optional(number)<br/>    ports                   = optional(list(number))<br/>    source_tags             = optional(list(string))<br/>    source_service_accounts = optional(list(string))<br/>    target_tags             = optional(list(string))<br/>    target_service_accounts = optional(list(string))<br/>    action                  = optional(string)<br/>    allow = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    deny = optional(list(object({<br/>      protocol = string<br/>      ports    = optional(list(string))<br/>    })))<br/>    enforcement = optional(bool)<br/>    disabled    = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_global_routing"></a> [global\_routing](#input\_global\_routing) | n/a | `bool` | `false` | no |
| <a name="input_ip_ranges"></a> [ip\_ranges](#input\_ip\_ranges) | n/a | <pre>list(object({<br/>    create      = optional(bool, true)<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    ip_range    = string<br/>    purpose     = optional(string, "VPC_PEERING")<br/>  }))</pre> | `[]` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | n/a | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network_firewall_policy_enforcement_order"></a> [network\_firewall\_policy\_enforcement\_order](#input\_network\_firewall\_policy\_enforcement\_order) | n/a | `string` | `"AFTER_CLASSIC_FIREWALL"` | no |
| <a name="input_peerings"></a> [peerings](#input\_peerings) | n/a | <pre>list(object({<br/>    create                              = optional(bool, true)<br/>    name                                = optional(string)<br/>    peer_project                        = optional(string)<br/>    peer_network                        = optional(string)<br/>    import_custom_routes                = optional(bool, false)<br/>    export_custom_routes                = optional(bool, false)<br/>    import_subnet_routes_with_public_ip = optional(bool, false)<br/>    export_subnet_routes_with_public_ip = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | n/a | <pre>list(object({<br/>    create            = optional(bool, true)<br/>    name              = optional(string)<br/>    description       = optional(string)<br/>    dest_range        = optional(string)<br/>    dest_ranges       = optional(list(string))<br/>    priority          = optional(number, 1000)<br/>    tags              = optional(list(string))<br/>    next_hop          = optional(string)<br/>    next_hop_gateway  = optional(string)<br/>    next_hop_instance = optional(string)<br/>    next_hop_zone     = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | n/a | `string` | `"REGIONAL"` | no |
| <a name="input_service_connections"></a> [service\_connections](#input\_service\_connections) | n/a | <pre>list(object({<br/>    create               = optional(bool, true)<br/>    name                 = optional(string)<br/>    service              = optional(string)<br/>    ip_ranges            = list(string)<br/>    import_custom_routes = optional(bool, false)<br/>    export_custom_routes = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_shared_accounts"></a> [shared\_accounts](#input\_shared\_accounts) | n/a | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | <pre>list(object({<br/>    create                   = optional(bool, true)<br/>    name                     = optional(string)<br/>    description              = optional(string)<br/>    region                   = optional(string)<br/>    stack_type               = optional(string)<br/>    ip_range                 = string<br/>    purpose                  = optional(string)<br/>    role                     = optional(string)<br/>    private_access           = optional(bool)<br/>    flow_logs                = optional(bool)<br/>    log_aggregation_interval = optional(string)<br/>    log_sampling_rate        = optional(number)<br/>    attached_projects        = optional(list(string))<br/>    shared_accounts          = optional(list(string))<br/>    viewer_accounts          = optional(list(string))<br/>    secondary_ranges = optional(list(object({<br/>      name  = optional(string)<br/>      range = string<br/>    })))<br/>    psc_endpoints = optional(list(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      address     = optional(string)<br/>      target      = string<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_viewer_accounts"></a> [viewer\_accounts](#input\_viewer\_accounts) | n/a | `list(string)` | `[]` | no |
| <a name="input_vpc_access_connectors"></a> [vpc\_access\_connectors](#input\_vpc\_access\_connectors) | n/a | <pre>list(object({<br/>    create         = optional(bool, true)<br/>    name           = optional(string)<br/>    region         = optional(string)<br/>    cidr_range     = optional(string)<br/>    subnet         = optional(string)<br/>    min_throughput = optional(number)<br/>    max_throughput = optional(number)<br/>    min_instances  = optional(number)<br/>    max_instances  = optional(number)<br/>    machine_type   = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_nats"></a> [cloud\_nats](#output\_cloud\_nats) | n/a |
| <a name="output_cloud_routers"></a> [cloud\_routers](#output\_cloud\_routers) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_peering_connections"></a> [peering\_connections](#output\_peering\_connections) | n/a |
| <a name="output_project"></a> [project](#output\_project) | n/a |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
<!-- END_TF_DOCS -->