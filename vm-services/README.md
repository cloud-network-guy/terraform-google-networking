<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance"></a> [instance](#module\_instance) | ../modules/instance | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_deployments"></a> [deployments](#input\_deployments) | Regions to deploy instances to | <pre>map(object({<br/>    create                 = optional(bool)<br/>    name                   = optional(string)<br/>    region                 = optional(string)<br/>    zone                   = optional(string)<br/>    machine_type           = optional(string)<br/>    disk_image             = optional(string)<br/>    disk_type              = optional(string)<br/>    disk_size              = optional(number)<br/>    os_project             = optional(string)<br/>    os                     = optional(string)<br/>    network                = optional(string)<br/>    subnetwork             = optional(string)<br/>    startup_script         = optional(string)<br/>    network_tags           = optional(list(string))<br/>    service_account_email  = optional(string)<br/>    service_account_scopes = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_disk_image"></a> [disk\_image](#input\_disk\_image) | Image to use | `string` | `null` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size in GB | `number` | `10` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk Type | `string` | `"pd-standard"` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | If using Shared VPC, the Project ID that hosts the VPC network | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(any)` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine Type | `string` | `"e2-small"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the instances | `string` | `"instance"` | no |
| <a name="input_network"></a> [network](#input\_network) | Name of the VPC Network | `string` | `null` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | List of Network Tags | `list(string)` | `null` | no |
| <a name="input_os"></a> [os](#input\_os) | GCP OS Name | `string` | `"debian-12"` | no |
| <a name="input_os_project"></a> [os\_project](#input\_os\_project) | GCP OS Project | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Default Region | `string` | `null` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Service Account e-mail address | `string` | `null` | no |
| <a name="input_service_account_scopes"></a> [service\_account\_scopes](#input\_service\_account\_scopes) | List of Service Account Scopes | `list(string)` | <pre>[<br/>  "compute-rw",<br/>  "storage-rw",<br/>  "logging-write",<br/>  "monitoring"<br/>]</pre> | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | Startup Script | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances"></a> [instances](#output\_instances) | n/a |
<!-- END_TF_DOCS -->