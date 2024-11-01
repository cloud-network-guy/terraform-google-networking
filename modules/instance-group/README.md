<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16, < 7.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_region_instance_group_manager.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_healing_initial_delay"></a> [auto\_healing\_initial\_delay](#input\_auto\_healing\_initial\_delay) | n/a | `number` | `300` | no |
| <a name="input_autoscaling_mode"></a> [autoscaling\_mode](#input\_autoscaling\_mode) | n/a | `string` | `"OFF"` | no |
| <a name="input_base_instance_name"></a> [base\_instance\_name](#input\_base\_instance\_name) | n/a | `string` | `null` | no |
| <a name="input_cooldown_period"></a> [cooldown\_period](#input\_cooldown\_period) | n/a | `number` | `60` | no |
| <a name="input_cpu_predictive_method"></a> [cpu\_predictive\_method](#input\_cpu\_predictive\_method) | n/a | `string` | `"NONE"` | no |
| <a name="input_cpu_target"></a> [cpu\_target](#input\_cpu\_target) | n/a | `number` | `0.6` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_distribution_policy_target_shape"></a> [distribution\_policy\_target\_shape](#input\_distribution\_policy\_target\_shape) | n/a | `string` | `"EVEN"` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | n/a | `string` | `null` | no |
| <a name="input_healthchecks"></a> [healthchecks](#input\_healthchecks) | n/a | `list(string)` | `null` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | n/a | `string` | `null` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | n/a | `list(string)` | `null` | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | n/a | `number` | `10` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | n/a | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `null` | no |
| <a name="input_named_ports"></a> [named\_ports](#input\_named\_ports) | n/a | <pre>list(object({<br/>    name = optional(string)<br/>    port = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | n/a | `string` | `"default"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | n/a | `string` | `"default"` | no |
| <a name="input_target_size"></a> [target\_size](#input\_target\_size) | n/a | `number` | `2` | no |
| <a name="input_update"></a> [update](#input\_update) | n/a | <pre>object({<br/>    type                         = optional(string)<br/>    minimal_action               = optional(string)<br/>    most_disruptive_action       = optional(string)<br/>    replacement_method           = optional(string)<br/>    instance_redistribution_type = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_update_instance_redistribution_type"></a> [update\_instance\_redistribution\_type](#input\_update\_instance\_redistribution\_type) | n/a | `string` | `"PROACTIVE"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_instance_group"></a> [instance\_group](#output\_instance\_group) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
| <a name="output_zone"></a> [zone](#output\_zone) | n/a |
<!-- END_TF_DOCS -->