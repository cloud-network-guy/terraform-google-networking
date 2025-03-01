# Client (consumer) connection to a GCP Service using Private Service Connect 

## Resources

- [google_compute_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)
- [google_compute_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule)

## Inputs

### Required Inputs

| Name          | Description                                                  | Type     |
|---------------|--------------------------------------------------------------|----------|
| project\_id   | Project ID of the project to create the client connection in | `string` | 
| network\_name | Name of the VPC network on the client side                   | `string` |
| target\_id    | ID of Published PSC Service                                  | `string` |

### Optional Inputs

| Name                 | Description                                               | Type     | Default   |
|----------------------|-----------------------------------------------------------|----------|-----------|
| create               | Whether or not to create forwarding rule                  | `bool`   | true      |
| region               | Name of the network this set of firewall rules applies to | `string` | n/a       |
| subnet\_name         | Name of the subnet to create the IP address on            | `string` | "default" |
| subnet\_id           | ID of the subnet to create the IP address on              | `string` | n/a       |
| name                 | Explicit name for the PSC IP address and forwarding rule  | `string` | n/a       |
| description          | Description for the IP address                            | `string` | n/a       |
| network\_project\_id | If using Shared VPC, the host project ID for the network  | `string` | n/a       |
| target\_project\_id  | Project ID of Published PSC Service                       | `string` | n/a       |
| target\_name         | Name of Published PSC Service                             | `string` | n/a       |
| target\_region       | Region of Published PSC Service                           | `string` | n/a       |

#### Notes

- Either `target_id` or `target_name` must be provided
- If neither `target_id` nor `target_project_id` are provided, target project ID is assumed same as `var.project_id`
- If neither `target_id` nor `target_region` are provided, target region is assumed same as `var.region`
- If `var.region` is not specified, it is assumed to be same as Publisher
- If name is not specified, it will be auto-generated: `psc-endpoint-${REGION}-${SERVICE_NAME}`
- If description is not provided, it will be the target service ID

## Outputs

| Name    | Description                           | Type     |
|---------|---------------------------------------|----------|
| name    | The Name of the PSC Endpoint          | `string` |
| address | The IP Address of the Forwarding Rule | `string` |


### Examples

#### Basic Example with custom subnet name and PSC Service ID

```
project_id        = "my-project-id"
network_name      = "my-network-name"
subnet_name       = "my-subnet-name"
region            = "us-east4"
target_id         = "projects/another-project-id/regions/us-east4/serviceAttachments/service-name"
```

#### When local Network uses Shared VPC

```
project_id          = "my-project-id"
network_project_id  = "my-shared-vpc-host-project-id"
network_name        = "my-network-name"
subnet_name         = "my-subnet-name"
region              = "us-west2"
target_id           = "projects/another-project-id/regions/us-west2/serviceAttachments/service-name"
```

#### Auto-Generated Target Service ID

```
project_id        = "my-project-id"
network_name      = "my-network-name"
subnet_name       = "my-subnet-name"
region            = "us-east4"
target_project_id = "my-buddys-project"
target_name       = "my-buddys-service"
target_region     = "us-east4"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.49.0, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.49.0, < 7.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether or not to build forwarding rule | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the IP Address for the PSC Endpoint | `string` | `null` | no |
| <a name="input_global_access"></a> [global\_access](#input\_global\_access) | Allow access to forwarding rule from all regions | `bool` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the PSC Endpoint and IP Address | `string` | `null` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Local VPC Network Name | `string` | `"default"` | no |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | If using Shared VPC, the GCP Project ID for the host network | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID to create resources in | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region name for the IP address and forwarding rule | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnetwork ID (projects/PROJECT\_ID/regions/REGION/subnetworks/SUBNET\_NAME) | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnetwork Name | `string` | `"default"` | no |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | ID of the published service (projects/PUBLISHER\_PROJECT\_ID/regions/REGION/serviceAttachments/SERVICE\_NAME) | `string` | `null` | no |
| <a name="input_target_name"></a> [target\_name](#input\_target\_name) | Name of the published service | `string` | `null` | no |
| <a name="input_target_project_id"></a> [target\_project\_id](#input\_target\_project\_id) | Project ID of the published service | `string` | `null` | no |
| <a name="input_target_region"></a> [target\_region](#input\_target\_region) | Region of the published service | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_address_name"></a> [address\_name](#output\_address\_name) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_psc_connection_id"></a> [psc\_connection\_id](#output\_psc\_connection\_id) | n/a |
<!-- END_TF_DOCS -->