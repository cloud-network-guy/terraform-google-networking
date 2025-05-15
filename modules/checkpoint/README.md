# CheckPoint HA Cluster on Google Cloud Platform

## Resources Created

- [google_compute_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
- [google_compute_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)
- [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) 

## Inputs 

### Recommended Inputs

| Name        | Description                          | Type     | Default |
|-------------|--------------------------------------|----------|----|
| project\_id | GCP Project ID for all resources     | `string` | n/a |
| region      | GCP Name to create the gateway(s) in | `string` | n/a |
| name        | Name of the CheckPoint                  | `string` | n/a |
| description                     | Description for the instances                  | `string`       | n/a                     |
| install\_type     | Installation Type                           | `string` | Cluster |
| license\_type     | License Type.  Options are `BYOL` or `PAYG` | `string` | BYOL    |
| software\_version | Checkpoint Software Version                 | `string` | R81.10  |

#### Notes

- Supported Software versions are R80.40, R81.10, R81, and R81.20
- If `name` is not provided, it will be auto-generated

#### Install Types

- `Cluster` - High Availability Active/Passive Cluster
- `AutoScale` - Auto-Scaling Cluster
- `Gateway only` - Standalone Gateway
- `Management only` - Security Management Server
- `Manual Configuration` - 

### Optional Inputs

| Name                            | Description                                    | Type           | Default                 |
|---------------------------------|------------------------------------------------|----------------|-------------------------|
| zones                           | Short name of the zones to use in this region  | `list(string)` | ["b","c"]               |
| machine\_type                   | GCP Machine Type for the VMs                   | `string`       | n1-standard-4           |
| instances_suffixes              | Names to use for the end of each instance name | `list(string)` | ["member-a","member-b"] |
| disk\_type                      | Disk type for gateways                         | `string`       | pd-ssd                  |
| disk\_size                      | Disk size for gateways (in GB)                 | `number`       | 100                     |
| disk\_auto\_delete              | Auto delete disk when VM is deleted            | `bool`         | true                    |
| admin\_shell                    | Shell for the 'admin' user                     | `string`       | /etc/cli.sh             |
| admin\_password                 | Password for the 'admin' user                  | `string`       | n/a                     |
| sic\_key                        | Secure Internal Communication passkey          | `string`       | n/a                     |
| create_nic0_external_ips  | Create External IPs nic0 of each instance        | `bool`         | true                    |
| create_nic1_external_ips  | Create External IPs for nic1 of each instance       | `bool`         | true                    |
| allow_upload_download           | Allow Software updates via Web                 | `bool`         | false                   |
| enable\_monitoring              | Activate StackDriver Monitoring                | `bool`         | false                   |
| network\_tags                   | Network Tags to apply to instances              | `list(string)` | ["checkpoint-gateway"]  |
| create_instance_groups | Create Unmanaged Instance groups for non-autoscaled | `bool` | false |

### Notes

- Using custom `instance_suffixes` is not recommend for clusters as it will cause failover issues
- For Management-Only installs, default network tag is `["checkpoint-management"]`

## Outputs

| Name               | Description                                | Type           |
|--------------------|--------------------------------------------|----------------|
| name               | General name of the deployment             | `string`       |
| cluster\_address   | Primary Cluster Address of the Cluster     | `string`       |
| license\_type      | License type that was deployed             | `string`       |
| software\_version  | Software version that was deployed         | `string`       |
| image              | Specific software image used for the disks | `string`       |
| admin\_password    | Admin password for the gateways            | `string`       |
| sic\_key           | SIC key for the gateways                   | `string`       |
| instances          | Information about each specific instance   | `map`          |
| instance_group_ids | IDs of the instance groups created         | `list(string)` |

## Sample Inputs

### R81.10 PAYG cluster in us-central1

```
project_id             = "my-project-id"
install_type           = "Cluster
license_type           = "PAYG"
name                   = "my-cluster"
region                 = "us-central1"
network_names          = ["external", "mgmt", "internal"]
subnet_names           = ["default", "default", "default"]
allow_upload_download  = true
enable_monitoring      = true
```

### R81.10 BYOL standalones, 2 NIC deployment in us-east4 with custom machine type options

```
project_id             = "my-project-id"
name                   = "my-cluster"
region                 = "us-east4"
machine_type           = "n2-standard-2"
instance_suffixes      = ["01", "02"]
allow_upload_download  = true
enable_monitoring      = true
admin_password         = "abcxyz0123456789"
admin_shell            = "/bin/bash"
sic_key                = "abcd1234"
network_names          = ["external","internal"]
license_type           = "BYOL"
```


### R81.10 PAYG cluster in us-central1 with custom zone selection and no external IP for mgmt interfaces

```
project_id                = "my-project-id"
install_type              = "Cluster
name                      = "my-cluster"
region                    = "us-central1"
zones                     = ["c","f"]
license_type              = "PAYG"
create_nic1_external_ips  = false
```

### RR81.10 BYOL Management Server in us-east4

```
project_id        = "my-project-id"
install_type      = "Management only"
name              = "chkp-mgr"
region            = "us-east4"
network_name      = "default"
subnet_name       = "default"
machine_type      = "n2d-standard-4"
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16, < 7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.nic0_external_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.nic1_external_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk_resource_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk_resource_policy_attachment) | resource |
| [google_compute_instance.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_resource_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy) | resource |
| [google_compute_snapshot.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_snapshot) | resource |
| [random_string.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.sic_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_address.nic0_external_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | n/a | `string` | `null` | no |
| <a name="input_admin_shell"></a> [admin\_shell](#input\_admin\_shell) | n/a | `string` | `null` | no |
| <a name="input_admin_ssh_key"></a> [admin\_ssh\_key](#input\_admin\_ssh\_key) | n/a | `string` | `null` | no |
| <a name="input_allow_upload_download"></a> [allow\_upload\_download](#input\_allow\_upload\_download) | n/a | `bool` | `null` | no |
| <a name="input_allowed_gui_clients"></a> [allowed\_gui\_clients](#input\_allowed\_gui\_clients) | n/a | `string` | `null` | no |
| <a name="input_auto_scale"></a> [auto\_scale](#input\_auto\_scale) | n/a | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | n/a | `bool` | `true` | no |
| <a name="input_create_instance_groups"></a> [create\_instance\_groups](#input\_create\_instance\_groups) | n/a | `bool` | `false` | no |
| <a name="input_create_nic0_external_ips"></a> [create\_nic0\_external\_ips](#input\_create\_nic0\_external\_ips) | n/a | `bool` | `true` | no |
| <a name="input_create_nic1_external_ips"></a> [create\_nic1\_external\_ips](#input\_create\_nic1\_external\_ips) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `null` | no |
| <a name="input_disk_auto_delete"></a> [disk\_auto\_delete](#input\_disk\_auto\_delete) | n/a | `bool` | `null` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | n/a | `number` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | n/a | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | n/a | `string` | `null` | no |
| <a name="input_enable_disk_snapshot"></a> [enable\_disk\_snapshot](#input\_enable\_disk\_snapshot) | n/a | `bool` | `null` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | n/a | `bool` | `null` | no |
| <a name="input_enable_serial_port"></a> [enable\_serial\_port](#input\_enable\_serial\_port) | n/a | `bool` | `null` | no |
| <a name="input_expert_password"></a> [expert\_password](#input\_expert\_password) | n/a | `string` | `null` | no |
| <a name="input_flip_members"></a> [flip\_members](#input\_flip\_members) | For H/A Clusters, set member-b as active rather than member-a | `bool` | `false` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | n/a | `string` | `null` | no |
| <a name="input_install_type"></a> [install\_type](#input\_install\_type) | n/a | `string` | `null` | no |
| <a name="input_instance_suffixes"></a> [instance\_suffixes](#input\_instance\_suffixes) | n/a | `list(string)` | `null` | no |
| <a name="input_internal_routes"></a> [internal\_routes](#input\_internal\_routes) | n/a | `list(string)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(any)` | `null` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | n/a | `string` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | n/a | `string` | `null` | no |
| <a name="input_mgmt_routes"></a> [mgmt\_routes](#input\_mgmt\_routes) | n/a | `list(string)` | <pre>[<br/>  "10.0.0.0/8",<br/>  "172.16.0.0/12",<br/>  "192.168.0.0/16"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | n/a | `string` | `"default"` | no |
| <a name="input_network_names"></a> [network\_names](#input\_network\_names) | n/a | `list(string)` | `null` | no |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | Host Network's Project ID (if using Shared VPC) | `string` | `null` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | n/a | `list(string)` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID to deploy cluster in | `string` | `null` | no |
| <a name="input_proxy_host"></a> [proxy\_host](#input\_proxy\_host) | n/a | `string` | `null` | no |
| <a name="input_proxy_port"></a> [proxy\_port](#input\_proxy\_port) | n/a | `number` | `8080` | no |
| <a name="input_region"></a> [region](#input\_region) | Default region name to deploy in | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | n/a | `string` | `null` | no |
| <a name="input_service_account_scopes"></a> [service\_account\_scopes](#input\_service\_account\_scopes) | n/a | `list(string)` | `null` | no |
| <a name="input_sic_address"></a> [sic\_address](#input\_sic\_address) | n/a | `string` | `null` | no |
| <a name="input_sic_key"></a> [sic\_key](#input\_sic\_key) | n/a | `string` | `null` | no |
| <a name="input_smart_1_cloud_token_a"></a> [smart\_1\_cloud\_token\_a](#input\_smart\_1\_cloud\_token\_a) | (Optional) Smart-1 cloud token for member A to connect this Gateway to Check Point's Security Management as a Service | `string` | `""` | no |
| <a name="input_smart_1_cloud_token_b"></a> [smart\_1\_cloud\_token\_b](#input\_smart\_1\_cloud\_token\_b) | (Optional) Smart-1 cloud token for member B to connect this Gateway to Check Point's Security Management as a Service | `string` | `""` | no |
| <a name="input_software_image"></a> [software\_image](#input\_software\_image) | n/a | `string` | `null` | no |
| <a name="input_software_version"></a> [software\_version](#input\_software\_version) | n/a | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `string` | `null` | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | n/a | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | n/a | `string` | `"default"` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | n/a | `list(string)` | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | n/a | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | n/a |
| <a name="output_admin_shell"></a> [admin\_shell](#output\_admin\_shell) | n/a |
| <a name="output_cluster_address"></a> [cluster\_address](#output\_cluster\_address) | n/a |
| <a name="output_image"></a> [image](#output\_image) | n/a |
| <a name="output_install_type"></a> [install\_type](#output\_install\_type) | n/a |
| <a name="output_instance_group_ids"></a> [instance\_group\_ids](#output\_instance\_group\_ids) | n/a |
| <a name="output_instances"></a> [instances](#output\_instances) | n/a |
| <a name="output_license_type"></a> [license\_type](#output\_license\_type) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_sic_key"></a> [sic\_key](#output\_sic\_key) | n/a |
| <a name="output_software_version"></a> [software\_version](#output\_software\_version) | n/a |
<!-- END_TF_DOCS -->