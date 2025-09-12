<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_healthcheck"></a> [healthcheck](#module\_healthcheck) | ../modules/healthcheck | n/a |
| <a name="module_instance-groups"></a> [instance-groups](#module\_instance-groups) | ../modules/instance-group | n/a |
| <a name="module_instance-template"></a> [instance-template](#module\_instance-template) | ../modules/instance-template | n/a |
| <a name="module_lb-backend"></a> [lb-backend](#module\_lb-backend) | ../modules/lb-backend-new | n/a |
| <a name="module_lb-frontend"></a> [lb-frontend](#module\_lb-frontend) | ../modules/forwarding-rule | n/a |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.ops_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_mode"></a> [autoscaling\_mode](#input\_autoscaling\_mode) | n/a | `string` | `"OFF"` | no |
| <a name="input_cool_down_period"></a> [cool\_down\_period](#input\_cool\_down\_period) | n/a | `number` | `60` | no |
| <a name="input_cpu_predictive_method"></a> [cpu\_predictive\_method](#input\_cpu\_predictive\_method) | n/a | `string` | `null` | no |
| <a name="input_cpu_target"></a> [cpu\_target](#input\_cpu\_target) | n/a | `number` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_deployments"></a> [deployments](#input\_deployments) | Regions to deploy instances and/or iLB to | <pre>map(object({<br/>    enabled               = optional(bool)<br/>    create_ilb            = optional(bool)<br/>    region                = optional(string)<br/>    machine_type          = optional(string)<br/>    disk_type             = optional(string)<br/>    disk_size             = optional(number)<br/>    os_project            = optional(string)<br/>    os                    = optional(string)<br/>    startup_script        = optional(string)<br/>    network               = optional(string)<br/>    subnet                = optional(string)<br/>    ip_address            = optional(string)<br/>    ip_address_name       = optional(string)<br/>    ports                 = optional(list(number))<br/>    forwarding_rule_name  = optional(string)<br/>    target_size           = optional(number)<br/>    min_replicas          = optional(number)<br/>    max_replicas          = optional(number)<br/>    global_access         = optional(bool)<br/>    cpu_target            = optional(number)<br/>    cpu_predictive_method = optional(string)<br/>    instance_groups = optional(list(object({<br/>      id        = optional(string)<br/>      name      = optional(string)<br/>      zone      = optional(string)<br/>      instances = optional(list(string))<br/>    })))<br/>    psc = optional(object({<br/>      name                        = optional(string)<br/>      nat_subnets                 = optional(list(string))<br/>      auto_accept_all_connections = optional(bool)<br/>      accept_projects = optional(list(object({<br/>        project          = string<br/>        connection_limit = optional(number)<br/>      })))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size in GB | `number` | `12` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk Type | `string` | `"pd-standard"` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | Allow access to LB from outside of local region (ILB only) | `bool` | `false` | no |
| <a name="input_healthcheck_interval"></a> [healthcheck\_interval](#input\_healthcheck\_interval) | n/a | `number` | `10` | no |
| <a name="input_healthcheck_logging"></a> [healthcheck\_logging](#input\_healthcheck\_logging) | n/a | `bool` | `false` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | If using Shared VPC, the Project ID that hosts the VPC network | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(any)` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine Type | `string` | `"e2-small"` | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | n/a | `number` | `null` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | n/a | `number` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the instances and load balancer | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name of the VPC Network | `string` | `null` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | List of Network Tags | `list(string)` | `null` | no |
| <a name="input_os"></a> [os](#input\_os) | GCP OS Name | `string` | `"debian-12"` | no |
| <a name="input_os_project"></a> [os\_project](#input\_os\_project) | GCP OS Project | `string` | `"debian-cloud"` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | List of ports to forward on the frontend of the load balancer | `list(string)` | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `null` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Service Account e-mail address | `string` | `null` | no |
| <a name="input_service_account_scopes"></a> [service\_account\_scopes](#input\_service\_account\_scopes) | List of Service Account Scopes | `list(string)` | <pre>[<br/>  "compute-rw",<br/>  "storage-rw",<br/>  "logging-write",<br/>  "monitoring"<br/>]</pre> | no |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | Session affinity type for backend | `string` | `"NONE"` | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | Startup Script | `string` | `null` | no |
| <a name="input_target_size"></a> [target\_size](#input\_target\_size) | n/a | `number` | `null` | no |
| <a name="input_update_type"></a> [update\_type](#input\_update\_type) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connected_endpoints"></a> [connected\_endpoints](#output\_connected\_endpoints) | n/a |
| <a name="output_ilbs_addresses"></a> [ilbs\_addresses](#output\_ilbs\_addresses) | n/a |
| <a name="output_mig_ids"></a> [mig\_ids](#output\_mig\_ids) | n/a |
| <a name="output_umig_ids"></a> [umig\_ids](#output\_umig\_ids) | n/a |
| <a name="output_zones"></a> [zones](#output\_zones) | n/a |
<!-- END_TF_DOCS -->