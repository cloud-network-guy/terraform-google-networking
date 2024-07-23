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
| org_id          | Project ID of the GCP project                              | `number`       | n/a     |
| folder_id       | Project ID of the GCP project                              | `number`       | n/a     |
| project_ids     | Project ID of the GCP project                              | `list(string)` | n/a     |
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