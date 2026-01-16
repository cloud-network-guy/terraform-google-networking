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
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12.0, < 8.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.12.0, < 8.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.15.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 7.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_shared_vpc_service_project.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_service_project) | resource |
| [google_compute_subnetwork_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google_compute_subnetwork_iam_binding.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google_compute_subnetwork_iam_binding.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google_project_iam_member.gke_host_service_agent_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_project_network_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google-beta_google_cloud_asset_resources_search_all.services](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/data-sources/google_cloud_asset_resources_search_all) | data source |
| [google_project.service_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_give_gke_project_viewer_access"></a> [give\_gke\_project\_viewer\_access](#input\_give\_gke\_project\_viewer\_access) | Give GKE Service Accounts Compute Network Viewer permissions on the Host Network Project | `bool` | `false` | no |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | For Shared VPC, Project ID of the Host Network Project | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC Network Name, ID, or Self LInk | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Default Region | `string` | `null` | no |
| <a name="input_subnetworks"></a> [subnetworks](#input\_subnetworks) | n/a | <pre>list(object({<br/>    id                = optional(string)<br/>    name              = optional(string)<br/>    region            = optional(string)<br/>    purpose           = optional(string)<br/>    attached_projects = optional(list(string))<br/>    shared_accounts   = optional(list(string))<br/>    viewer_accounts   = optional(list(string))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->