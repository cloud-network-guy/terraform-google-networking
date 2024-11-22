# terraform-google-netsec
Network Security Resources in Google Cloud Platform (Firewall Policies, Cloud Armor, Secure Web Proxy, etc)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49.0, < 7.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.49.0, < 7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.external_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_instance.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_network_firewall_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy) | resource |
| [google_compute_network_firewall_policy_association.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_association) | resource |
| [google_compute_network_firewall_policy_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_region_network_firewall_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy) | resource |
| [google_compute_region_network_firewall_policy_association.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_association) | resource |
| [google_network_security_address_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_address_group) | resource |
| [random_string.checkpoint_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.checkpoint_sic_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_address.external_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address) | data source |
| [google_netblock_ip_ranges.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_groups"></a> [address\_groups](#input\_address\_groups) | n/a | <pre>list(object({<br/>    create      = optional(bool, true)<br/>    project_id  = optional(string)<br/>    org_id      = optional(number)<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    parent      = optional(string)<br/>    region      = optional(string)<br/>    type        = optional(string)<br/>    capacity    = optional(number)<br/>    items       = list(string)<br/>    labels      = optional(map(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_checkpoints"></a> [checkpoints](#input\_checkpoints) | List of Checkpoint CloudGuards | <pre>list(object({<br/>    create                 = optional(bool, true)<br/>    project_id             = optional(string)<br/>    host_project_id        = optional(string)<br/>    name                   = string<br/>    region                 = string<br/>    zone                   = optional(string)<br/>    description            = optional(string)<br/>    install_type           = optional(string)<br/>    instance_suffixes      = optional(string)<br/>    zones                  = optional(list(string))<br/>    machine_type           = optional(string)<br/>    disk_type              = optional(string)<br/>    disk_size              = optional(number)<br/>    disk_auto_delete       = optional(bool)<br/>    admin_password         = optional(string)<br/>    expert_password        = optional(string)<br/>    sic_key                = optional(string)<br/>    allow_upload_download  = optional(bool)<br/>    enable_monitoring      = optional(bool)<br/>    license_type           = optional(string)<br/>    image                  = optional(string)<br/>    software_version       = optional(string)<br/>    ssh_key                = optional(string)<br/>    startup_script         = optional(string)<br/>    admin_shell            = optional(string)<br/>    admin_ssh_key          = optional(string)<br/>    service_account_email  = optional(string)<br/>    service_account_scopes = optional(list(string))<br/>    labels                 = optional(map(string))<br/>    network_tags           = optional(list(string))<br/>    nics = list(object({<br/>      network            = optional(string)<br/>      subnet             = optional(string)<br/>      create_external_ip = optional(bool)<br/>    }))<br/>    create_instance_groups = optional(bool)<br/>    allowed_gui_clients    = optional(string)<br/>    sic_address            = optional(string)<br/>    auto_scale             = optional(bool)<br/>    domain_name            = optional(string)<br/>    mgmt_routes            = optional(list(string))<br/>    internal_routes        = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_firewall_policies"></a> [firewall\_policies](#input\_firewall\_policies) | List of Policies | <pre>list(object({<br/>    create      = optional(bool, true)<br/>    project_id  = optional(string)<br/>    org_id      = optional(number)<br/>    name        = optional(string)<br/>    description = optional(string)<br/>    type        = optional(string)<br/>    networks    = optional(list(string))<br/>    region      = optional(string)<br/>    rules = optional(list(object({<br/>      create                     = optional(bool, true)<br/>      priority                   = optional(number)<br/>      description                = optional(string)<br/>      direction                  = optional(string)<br/>      ranges                     = optional(list(string))<br/>      range                      = optional(string)<br/>      source_ranges              = optional(list(string))<br/>      destination_ranges         = optional(list(string))<br/>      address_groups             = optional(list(string))<br/>      range_types                = optional(list(string))<br/>      range_type                 = optional(string)<br/>      protocol                   = optional(string)<br/>      protocols                  = optional(list(string))<br/>      port                       = optional(number)<br/>      ports                      = optional(list(number))<br/>      source_address_groups      = optional(list(string))<br/>      destination_address_groups = optional(list(string))<br/>      target_tags                = optional(list(string))<br/>      target_service_accounts    = optional(list(string))<br/>      action                     = optional(string)<br/>      logging                    = optional(bool)<br/>      disabled                   = optional(bool)<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | Default Org ID Number (can be overridden at resource level) | `number` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->