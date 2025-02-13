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
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 6.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 5.16.0, < 6.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16.0, < 6.0.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 5.16.0, < 6.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.cloud_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_peering.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering_routes_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_compute_route.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_router.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_shared_vpc_service_project.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_service_project) | resource |
| [google_compute_subnetwork.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google_compute_subnetwork_iam_binding.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google_compute_subnetwork_iam_binding.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google_service_networking_connection.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_vpc_access_connector.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector) | resource |
| [null_resource.subnets](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.short_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google-beta_google_cloud_asset_resources_search_all.services](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_cloud_asset_resources_search_all) | data source |
| [google_netblock_ip_ranges.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |
| [google_project.service_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_defaults"></a> [defaults](#input\_defaults) | n/a | <pre>object({<br/>    cloud_router_bgp_asn                   = optional(number)<br/>    cloud_router_bgp_keepalive_interval    = optional(number)<br/>    subnet_stack_type                      = optional(string)<br/>    subnet_private_access                  = optional(bool)<br/>    subnet_flow_logs                       = optional(bool)<br/>    subnet_log_aggregation_interval        = optional(string)<br/>    subnet_log_sampling_rate               = optional(string)<br/>    cloud_nat_enable_dpa                   = optional(bool)<br/>    cloud_nat_enable_eim                   = optional(bool)<br/>    cloud_nat_udp_idle_timeout             = optional(number)<br/>    cloud_nat_tcp_established_idle_timeout = optional(number)<br/>    cloud_nat_tcp_time_wait_timeout        = optional(number)<br/>    cloud_nat_tcp_transitory_idle_timeout  = optional(number)<br/>    cloud_nat_icmp_idle_timeout            = optional(number)<br/>    cloud_nat_min_ports_per_vm             = optional(number)<br/>    cloud_nat_max_ports_per_vm             = optional(number)<br/>    cloud_nat_log_type                     = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Default GCP Region Name (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_vpc_networks"></a> [vpc\_networks](#input\_vpc\_networks) | n/a | <pre>list(object({<br/>    create                   = optional(bool, true)<br/>    project_id               = optional(string)<br/>    name                     = string<br/>    description              = optional(string)<br/>    mtu                      = optional(number)<br/>    enable_global_routing    = optional(bool)<br/>    auto_create_subnetworks  = optional(bool)<br/>    enable_ula_internal_ipv6 = optional(bool)<br/>    attached_projects        = optional(list(string))<br/>    shared_accounts          = optional(list(string))<br/>    viewer_accounts          = optional(list(string))<br/>    subnets = optional(list(object({<br/>      create                   = optional(bool, true)<br/>      project_id               = optional(string)<br/>      name                     = optional(string)<br/>      description              = optional(string)<br/>      region                   = optional(string)<br/>      stack_type               = optional(string)<br/>      ip_range                 = string<br/>      purpose                  = optional(string)<br/>      role                     = optional(string)<br/>      private_access           = optional(bool)<br/>      flow_logs                = optional(bool)<br/>      log_aggregation_interval = optional(string)<br/>      log_sampling_rate        = optional(number)<br/>      attached_projects        = optional(list(string))<br/>      shared_accounts          = optional(list(string))<br/>      viewer_accounts          = optional(list(string))<br/>      secondary_ranges = optional(list(object({<br/>        name  = optional(string)<br/>        range = string<br/>      })))<br/>      psc_endpoints = optional(list(object({<br/>        project_id  = optional(string)<br/>        name        = optional(string)<br/>        description = optional(string)<br/>        address     = optional(string)<br/>        target      = string<br/>      })))<br/>    })))<br/>    routes = optional(list(object({<br/>      create            = optional(bool, true)<br/>      project_id        = optional(string)<br/>      name              = optional(string)<br/>      description       = optional(string)<br/>      dest_range        = optional(string)<br/>      dest_ranges       = optional(list(string))<br/>      priority          = optional(number)<br/>      tags              = optional(list(string))<br/>      next_hop          = optional(string)<br/>      next_hop_gateway  = optional(string)<br/>      next_hop_instance = optional(string)<br/>      next_hop_zone     = optional(string)<br/>    })))<br/>    peerings = optional(list(object({<br/>      create                              = optional(bool, true)<br/>      project_id                          = optional(string)<br/>      name                                = optional(string)<br/>      peer_project_id                     = optional(string)<br/>      peer_network_name                   = optional(string)<br/>      peer_network_link                   = optional(string)<br/>      import_custom_routes                = optional(bool)<br/>      export_custom_routes                = optional(bool)<br/>      import_subnet_routes_with_public_ip = optional(bool)<br/>      export_subnet_routes_with_public_ip = optional(bool)<br/>    })))<br/>    ip_ranges = optional(list(object({<br/>      create      = optional(bool, true)<br/>      project_id  = optional(string)<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      ip_range    = string<br/>    })))<br/>    service_connections = optional(list(object({<br/>      create               = optional(bool, true)<br/>      project_id           = optional(string)<br/>      name                 = optional(string)<br/>      service              = optional(string)<br/>      ip_ranges            = list(string)<br/>      import_custom_routes = optional(bool)<br/>      export_custom_routes = optional(bool)<br/>    })))<br/>    cloud_routers = optional(list(object({<br/>      create                        = optional(bool, true)<br/>      project_id                    = optional(string)<br/>      name                          = optional(string)<br/>      description                   = optional(string)<br/>      encrypted_interconnect_router = optional(bool)<br/>      region                        = optional(string)<br/>      enable_bgp                    = optional(bool)<br/>      bgp_asn                       = optional(number)<br/>      bgp_keepalive_interval        = optional(number)<br/>      advertised_groups             = optional(list(string))<br/>      advertised_ip_ranges = optional(list(object({<br/>        create      = optional(bool)<br/>        range       = string<br/>        description = optional(string)<br/>      })))<br/>    })))<br/>    cloud_nats = optional(list(object({<br/>      create            = optional(bool, true)<br/>      project_id        = optional(string)<br/>      name              = optional(string)<br/>      region            = optional(string)<br/>      cloud_router      = optional(string)<br/>      cloud_router_name = optional(string)<br/>      subnets           = optional(list(string))<br/>      num_static_ips    = optional(number)<br/>      static_ips = optional(list(object({<br/>        name        = optional(string)<br/>        description = optional(string)<br/>        address     = optional(string)<br/>      })))<br/>      log_type                     = optional(string)<br/>      enable_dpa                   = optional(bool)<br/>      min_ports_per_vm             = optional(number)<br/>      max_ports_per_vm             = optional(number)<br/>      enable_eim                   = optional(bool)<br/>      udp_idle_timeout             = optional(number)<br/>      tcp_established_idle_timeout = optional(number)<br/>      tcp_time_wait_timeout        = optional(number)<br/>      tcp_transitory_idle_timeout  = optional(number)<br/>      icmp_idle_timeout            = optional(number)<br/>    })))<br/>    vpc_access_connectors = optional(list(object({<br/>      create          = optional(bool, true)<br/>      project_id      = optional(string)<br/>      host_project_id = optional(string)<br/>      network         = optional(string)<br/>      name            = optional(string)<br/>      region          = optional(string)<br/>      cidr_range      = optional(string)<br/>      subnet          = optional(string)<br/>      min_throughput  = optional(number)<br/>      max_throughput  = optional(number)<br/>      min_instances   = optional(number)<br/>      max_instances   = optional(number)<br/>      machine_type    = optional(string)<br/>    })))<br/>    firewall_rules = optional(list(object({<br/>      create                  = optional(bool, true)<br/>      project_id              = optional(string)<br/>      network                 = optional(string)<br/>      name                    = optional(string)<br/>      name_prefix             = optional(string)<br/>      short_name              = optional(string)<br/>      description             = optional(string)<br/>      priority                = optional(number)<br/>      logging                 = optional(bool)<br/>      direction               = optional(string)<br/>      ranges                  = optional(list(string))<br/>      range                   = optional(string)<br/>      source_ranges           = optional(list(string))<br/>      destination_ranges      = optional(list(string))<br/>      range_types             = optional(list(string))<br/>      range_type              = optional(string)<br/>      protocol                = optional(string)<br/>      protocols               = optional(list(string))<br/>      port                    = optional(number)<br/>      ports                   = optional(list(number))<br/>      source_tags             = optional(list(string))<br/>      source_service_accounts = optional(list(string))<br/>      target_tags             = optional(list(string))<br/>      target_service_accounts = optional(list(string))<br/>      action                  = optional(string)<br/>      allow = optional(list(object({<br/>        protocol = string<br/>        ports    = optional(list(string))<br/>      })))<br/>      deny = optional(list(object({<br/>        protocol = string<br/>        ports    = optional(list(string))<br/>      })))<br/>      enforcement = optional(bool)<br/>      disabled    = optional(bool)<br/>    })))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_shared_subnets"></a> [shared\_subnets](#output\_shared\_subnets) | output "projects" { value = local.projects } output "service\_accounts" { value = local.service\_accounts } output "gke\_shared\_subnets" { value = local.gke\_shared\_subnets } |
| <a name="output_vpc_networks"></a> [vpc\_networks](#output\_vpc\_networks) | VPC Networks |
<!-- END_TF_DOCS -->