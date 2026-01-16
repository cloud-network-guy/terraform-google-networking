<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49.0, < 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.49.0, < 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_instance_template.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_autoscaler.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler) | resource |
| [google_compute_region_instance_group_manager.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | Default Shared VPC Host Project (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_instance_templates"></a> [instance\_templates](#input\_instance\_templates) | List of Instance Templates | <pre>list(object({<br/>    create                 = optional(bool, true)<br/>    project_id             = optional(string)<br/>    host_project_id        = optional(string)<br/>    name_prefix            = optional(string)<br/>    name                   = optional(string)<br/>    description            = optional(string)<br/>    region                 = string<br/>    zone                   = optional(string)<br/>    network                = optional(string)<br/>    subnet                 = optional(string)<br/>    machine_type           = optional(string)<br/>    disk_boot              = optional(bool)<br/>    disk_auto_delete       = optional(bool)<br/>    disk_type              = optional(string)<br/>    disk_size              = optional(number)<br/>    image                  = optional(string)<br/>    os                     = optional(string)<br/>    os_project             = optional(string)<br/>    startup_script         = optional(string)<br/>    service_account_email  = optional(string)<br/>    service_account_scopes = optional(list(string))<br/>    network_tags           = optional(list(string))<br/>    labels                 = optional(map(string))<br/>    metadata               = optional(map(string))<br/>    ssh_key                = optional(string)<br/>    can_ip_forward         = optional(bool)<br/>    nat_ips                = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | List of Standalone Instances | <pre>list(object({<br/>    create                    = optional(bool, true)<br/>    project_id                = optional(string)<br/>    host_project_id           = optional(string)<br/>    name                      = optional(string)<br/>    name_prefix               = optional(string)<br/>    description               = optional(string)<br/>    region                    = optional(string)<br/>    zone                      = optional(string)<br/>    network                   = optional(string)<br/>    subnet                    = optional(string)<br/>    machine_type              = optional(string)<br/>    boot_disk_type            = optional(string)<br/>    boot_disk_size            = optional(number)<br/>    image                     = optional(string)<br/>    os                        = optional(string)<br/>    os_project                = optional(string)<br/>    startup_script            = optional(string)<br/>    service_account_email     = optional(string)<br/>    service_account_scopes    = optional(list(string))<br/>    network_tags              = optional(list(string))<br/>    labels                    = optional(map(string))<br/>    can_ip_forward            = optional(bool)<br/>    delete_protection         = optional(bool)<br/>    allow_stopping_for_update = optional(bool)<br/>    nat_ips = optional(list(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      address     = optional(string)<br/>    })))<br/>    nat_ip_addresses = optional(list(string))<br/>    nat_ip_names     = optional(list(string))<br/>    ssh_key          = optional(string)<br/>    create_umig      = optional(bool)<br/>    public_zone      = optional(string)<br/>    private_zone     = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_migs"></a> [migs](#input\_migs) | List of Managed Instance Groups | <pre>list(object({<br/>    create                              = optional(bool, true)<br/>    project_id                          = optional(string)<br/>    name                                = optional(string)<br/>    name_prefix                         = optional(string)<br/>    base_instance_name                  = optional(string)<br/>    region                              = string<br/>    target_size                         = optional(number)<br/>    update_instance_redistribution_type = optional(string)<br/>    distribution_policy_target_shape    = optional(string)<br/>    update_type                         = optional(string)<br/>    update_minimal_action               = optional(string)<br/>    update_most_disruptive_action       = optional(string)<br/>    update_replacement_method           = optional(string)<br/>    auto_healing_initial_delay          = optional(number)<br/>    healthchecks = list(object({<br/>      id   = optional(string)<br/>      name = optional(string)<br/>    }))<br/>    autoscaling_mode      = optional(string)<br/>    min_replicas          = optional(number)<br/>    max_replicas          = optional(number)<br/>    cpu_target            = optional(number)<br/>    cpu_predictive_method = optional(string)<br/>    cooldown_period       = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_negs"></a> [negs](#input\_negs) | List of Network Endpoint Groups | <pre>list(object({<br/>    create          = optional(bool, true)<br/>    project_id      = optional(string)<br/>    host_project_id = optional(string)<br/>    name            = optional(string)<br/>    type            = optional(string)<br/>    region          = optional(string)<br/>    zone            = optional(string)<br/>    network         = optional(string)<br/>    subnet          = optional(string)<br/>    protocol        = optional(string)<br/>    default_port    = optional(number)<br/>    endpoints = optional(list(object({<br/>      instance   = optional(string)<br/>      fqdn       = optional(string)<br/>      ip_address = optional(string)<br/>      protocol   = optional(string)<br/>      port       = optional(number)<br/>      psc_target = optional(string)<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Default GCP Region Name (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_umigs"></a> [umigs](#input\_umigs) | List of Unmanaged Instance Groups | <pre>list(object({<br/>    create          = optional(bool, true)<br/>    project_id      = optional(string)<br/>    host_project_id = optional(string)<br/>    name            = optional(string)<br/>    network         = optional(string)<br/>    zone            = string<br/>    instances       = optional(list(string))<br/>    named_ports = optional(list(object({<br/>      name = string<br/>      port = number<br/>    })))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscalers"></a> [autoscalers](#output\_autoscalers) | Auto Scalers |
| <a name="output_instances"></a> [instances](#output\_instances) | Instances |
| <a name="output_migs"></a> [migs](#output\_migs) | Managed Instance Groups |
| <a name="output_umigs"></a> [umigs](#output\_umigs) | Unmanaged Instance Groups |
<!-- END_TF_DOCS -->