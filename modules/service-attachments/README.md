# Publish GCP Service via Private Service Connect

## Resources

- [google_compute_service_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment)

## Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| project\_id | Project ID to publish the service in | `string` | 
| nat\_subnet\_names | Names of the subnet(s) to use on the publisher side | `list(string)` | 

### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| target\_service\_id | ID of the Published Service.  Usually a forwarding rule | `string` | n/a |
| forwarding\_rule\_name | Name of the forwarding rule to publish (assumes same project) | `string` | n/a |
| name | Name to be given to the PSC published service  | `string` | n/a |
| description | Description for the service attachment | `string` | n/a |
| region | GCP Region to publish the service in | `string` | n/a |

#### Notes

- Either `target_service_id` or `forwarding_rule_name` must be provided
- If region is not specified, it is assumed to be same as the published service
- If name is not specified, it will be auto-generated: `psc-${REGION}-${SERVICE_NAME}`

## Outputs

| Name | Description | Type |
|------|-------------|------|
| self_link | URL of the Published Service | `string` |

### Usage Examples

#### Target Service ID Explicitly given

```
project_id         = "my-project-id"
target_service_id  = "projects/my-project-id/regions/us-central1/forwardingRules/my-serivce"
nat_subnet_names  = ["mynetwork-psc-subnet1"]
```

#### Region and Forwarding Rule name provided

```
project_id            = "my-project-id"
region                = "us-central1"
forwarding_rule_name  = "my-forwarding-rule"
nat_subnet_names      = ["mynetwork-psc-subnet1"]
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.7.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.7.0, < 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_service_attachment.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | Default Shared VPC Host Project (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Default GCP Project ID (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Default GCP Region Name (can be overridden at resource level) | `string` | `null` | no |
| <a name="input_service_attachments"></a> [service\_attachments](#input\_service\_attachments) | Services Published via PSC | <pre>list(object({<br/>    create                   = optional(bool, true)<br/>    project_id               = optional(string)<br/>    name                     = optional(string)<br/>    description              = optional(string)<br/>    region                   = optional(string)<br/>    forwarding_rule_name     = optional(string)<br/>    target_service_id        = optional(string)<br/>    nat_subnet_ids           = optional(list(string))<br/>    nat_subnet_names         = optional(list(string))<br/>    network_project_id       = optional(string)<br/>    enable_proxy_protocol    = optional(bool)<br/>    auto_accept_all_projects = optional(bool)<br/>    accept_project_ids = optional(list(object({<br/>      project_id       = string<br/>      connection_limit = optional(number)<br/>    })))<br/>    domain_names          = optional(list(string))<br/>    consumer_reject_lists = optional(list(string))<br/>    reconcile_connections = optional(bool)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_attachments"></a> [service\_attachments](#output\_service\_attachments) | PSC Published Services |
<!-- END_TF_DOCS -->