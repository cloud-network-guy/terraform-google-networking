<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ncc"></a> [ncc](#module\_ncc) | terraform-google-modules/network/google//modules/network-connectivity-center | ~> 18.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_export_psc"></a> [export\_psc](#input\_export\_psc) | Whether Private Service Connect transitivity is enabled for the hub | `bool` | `false` | no |
| <a name="input_hybrid_spokes"></a> [hybrid\_spokes](#input\_hybrid\_spokes) | VLAN attachments and VPN Tunnels that are associated with the spoke. Type must be one of `interconnect` and `vpn`. | <pre>map(object({<br/>    location                   = string<br/>    uris                       = optional(list(string), [])<br/>    site_to_site_data_transfer = optional(bool, false)<br/>    type                       = string<br/>    description                = optional(string)<br/>    labels                     = optional(map(string))<br/>    include_import_ranges      = optional(list(string), [])<br/>    group                      = optional(string)<br/>    attachments                = optional(list(string), [])<br/>    vpns                       = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_ncc_groups"></a> [ncc\_groups](#input\_ncc\_groups) | Groups for Hubs using the star topolgy | <pre>map(object({<br/>    name                 = optional(string)<br/>    labels               = optional(map(string))<br/>    description          = optional(string)<br/>    auto_accept_projects = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_ncc_hub_description"></a> [ncc\_hub\_description](#input\_ncc\_hub\_description) | The description of the NCC Hub | `string` | `null` | no |
| <a name="input_ncc_hub_labels"></a> [ncc\_hub\_labels](#input\_ncc\_hub\_labels) | These labels will be added the NCC hub | `map(string)` | `{}` | no |
| <a name="input_ncc_hub_name"></a> [ncc\_hub\_name](#input\_ncc\_hub\_name) | The Name of the NCC Hub | `string` | n/a | yes |
| <a name="input_ncc_hub_policy_mode"></a> [ncc\_hub\_policy\_mode](#input\_ncc\_hub\_policy\_mode) | The policy mode of the hub. Type must be one of `PRESET` or `CUSTOM`. | `string` | `"PRESET"` | no |
| <a name="input_ncc_hub_preset_topology"></a> [ncc\_hub\_preset\_topology](#input\_ncc\_hub\_preset\_topology) | The topology implemented in the hub. Type must be one of `STAR`, `MESH` or `HYBRID_INSPECTION`. | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_router_appliance_spokes"></a> [router\_appliance\_spokes](#input\_router\_appliance\_spokes) | Router appliance instances that are associated with the spoke. | <pre>map(object({<br/>    instances = set(object({<br/>      virtual_machine = string<br/>      ip_address      = string<br/>    }))<br/>    location                   = string<br/>    site_to_site_data_transfer = optional(bool, false)<br/>    description                = optional(string)<br/>    labels                     = optional(map(string))<br/>    include_import_ranges      = optional(list(string), [])<br/>    group                      = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_spoke_labels"></a> [spoke\_labels](#input\_spoke\_labels) | These labels will be added to all NCC spokes | `map(string)` | `{}` | no |
| <a name="input_vpc_spokes"></a> [vpc\_spokes](#input\_vpc\_spokes) | VPC network that is associated with the spoke. link\_producer\_vpc\_network: Producer VPC network that is peered with vpc network | <pre>map(object({<br/>    uri                   = string<br/>    exclude_export_ranges = optional(set(string), [])<br/>    include_export_ranges = optional(set(string), [])<br/>    description           = optional(string)<br/>    labels                = optional(map(string))<br/>    group                 = optional(string)<br/>    link_producer_vpc_network = optional(object({<br/>      network_name          = string<br/>      peering               = string<br/>      include_export_ranges = optional(list(string))<br/>      exclude_export_ranges = optional(list(string))<br/>      description           = optional(string)<br/>      labels                = optional(map(string))<br/>      group                 = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hybrid_spokes"></a> [hybrid\_spokes](#output\_hybrid\_spokes) | n/a |
| <a name="output_ncc_hub"></a> [ncc\_hub](#output\_ncc\_hub) | n/a |
| <a name="output_spokes"></a> [spokes](#output\_spokes) | n/a |
<!-- END_TF_DOCS -->