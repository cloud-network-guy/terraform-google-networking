<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns-policy"></a> [dns-policy](#module\_dns-policy) | ../modules/dns-policy | n/a |
| <a name="module_dns-zone"></a> [dns-zone](#module\_dns-zone) | ../modules/dns-zone | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.dns_policy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.dns_zone](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_dns_policies"></a> [dns\_policies](#input\_dns\_policies) | List of DNS Policies | <pre>map(object({<br/>    create                    = optional(bool, true)<br/>    project_id                = optional(string)<br/>    key                       = optional(string)<br/>    name                      = optional(string)<br/>    description               = optional(string)<br/>    logging                   = optional(bool)<br/>    enable_inbound_forwarding = optional(bool)<br/>    target_name_servers = optional(list(object({<br/>      ipv4_address    = optional(string)<br/>      forwarding_path = optional(string)<br/>    })))<br/>    networks = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_dns_zones"></a> [dns\_zones](#input\_dns\_zones) | List of DNS zones | <pre>map(object({<br/>    create          = optional(bool, true)<br/>    project_id      = optional(string)<br/>    host_project_id = optional(string)<br/>    host_project    = optional(string)<br/>    key             = optional(string)<br/>    dns_name        = string<br/>    name            = optional(string)<br/>    description     = optional(string)<br/>    visibility      = optional(string)<br/>    networks        = optional(list(string))<br/>    peer_project    = optional(string)<br/>    peer_network    = optional(string)<br/>    logging         = optional(bool)<br/>    force_destroy   = optional(bool)<br/>    target_name_servers = optional(list(object({<br/>      ipv4_address    = string<br/>      forwarding_path = optional(string, "default")<br/>    })))<br/>    records = optional(list(object({<br/>      create  = optional(bool, true)<br/>      key     = optional(string)<br/>      name    = string<br/>      type    = optional(string)<br/>      ttl     = optional(number)<br/>      rrdatas = list(string)<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | If using Shared VPC, the Project ID that hosts the VPC network | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | If using Shared VPC, the Project ID that hosts the VPC network | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_policies"></a> [dns\_policies](#output\_dns\_policies) | n/a |
| <a name="output_dns_zones"></a> [dns\_zones](#output\_dns\_zones) | n/a |
<!-- END_TF_DOCS -->