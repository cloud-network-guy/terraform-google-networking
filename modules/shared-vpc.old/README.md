# Shared VPC Module

Enabled Compute Network User role for project default service accounts on one a set of subnets

## Providers

- [google](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [google-beta](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs)

## Data Sources

- [google_compute_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects)
- [google_compute_regions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_regions)
- [google_compute_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/datasource_compute_network)
- [google_compute_networks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/datasource_compute_networks)
- [google_compute_subnetworks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetworks)
- [google_cloud_asset_resources_search_all](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/cloud_asset_resources_search_all)

## Resources 

- [google_compute_subnetwork_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam)

## Inputs 

### Input Variables

| Name            | Description                                                | Type           | Default |
|-----------------|------------------------------------------------------------|----------------|---------|
| host_project_id | Project ID of the Shared VPC Host Network Project          | `string`       | n/a     |
| org_id          | Org ID Containing Service Projects                         | `number`       | n/a     |
| folder_id       | Folder ID Containing Service Projects                      | `number`       | n/a     |
| project_ids     | Explicit list of Service Project IDs                       | `list(string)` | n/a     |
| network         | Specific Network name to enable permissions on             | `string`       | n/a     |
| regional_labels | Label keys to match regions to                             | `list(string)` | []      |
| regions         | Specific regions list to limit all queries to              | `list(string)` | []      |
| name_prefix     | If multiple regional networks, the prefix for each network | `string`       | n/a     |


### Input Examples

#### Use Project labels to give access to all projects in a specific folder

```terraform
host_project_id = "my-shared-vpc-host-project"
regional_labels = ["region", "location"]
folder_id       = 123456789022
```

#### Give all projects in the entire org access to subnets 


```terraform
host_project_id = "my-shared-vpc-host-project"
org_id          = 123456789022
```

##### Enable all subnets in certain regions to certain projects

```terraform
host_project_id = "my-shared-vpc-host-project"
network         = "shared-network-1"
project_ids     = ["project-1234", "project-5678"]
regions         = ["europe-west1", "europe-west4"]
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.34.0, < 6.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 5.34.0, < 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.34.0, < 6.0.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 5.34.0, < 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_subnetwork_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google-beta_google_cloud_asset_resources_search_all.services](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_cloud_asset_resources_search_all) | data source |
| [google_compute_network.shared_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_networks.shared_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_networks) | data source |
| [google_compute_regions.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_regions) | data source |
| [google_compute_subnetworks.private_subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetworks) | data source |
| [google_projects.active_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_credentials_file"></a> [credentials\_file](#input\_credentials\_file) | GCP service account JSON key | `string` | `null` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Folder ID containing list of Projects to examine | `string` | `null` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | For Shared VPC, Project ID of the Host Network Project | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name Prefix for Regional Networks | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Name of a specific VPC Network | `string` | `null` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | Organization ID containing list of Projects to examine | `string` | `null` | no |
| <a name="input_project_ids"></a> [project\_ids](#input\_project\_ids) | List of specific Project IDs to include | `list(string)` | `null` | no |
| <a name="input_regional_labels"></a> [regional\_labels](#input\_regional\_labels) | List of Fields to search for region | `list(string)` | `[]` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | List of Regions to limit Scope to | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active_projects"></a> [active\_projects](#output\_active\_projects) | output "shared\_subnets" { value = local.shared\_subnets } output "subnets" { value = local.subnets } output "service\_accounts" { value = local.service\_accounts } |
| <a name="output_active_regions"></a> [active\_regions](#output\_active\_regions) | n/a |
| <a name="output_attached_projects"></a> [attached\_projects](#output\_attached\_projects) | n/a |
| <a name="output_available_networks"></a> [available\_networks](#output\_available\_networks) | output "all\_networks" { value = local.all\_networks } |
<!-- END_TF_DOCS -->