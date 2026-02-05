<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.16.0, < 8.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.16.0, < 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.group_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.network_viewers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.user_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_roles"></a> [group\_roles](#input\_group\_roles) | Map of roles based on groups | `map(list(string))` | `{}` | no |
| <a name="input_network_viewers"></a> [network\_viewers](#input\_network\_viewers) | Service Accounts with Compute Network Viewer Permissions | `list(string)` | `[]` | no |
| <a name="input_org_domain"></a> [org\_domain](#input\_org\_domain) | GCP Organizational Domain | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `null` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Service Accounts | <pre>map(object({<br/>    create       = optional(bool, true)<br/>    account_id   = optional(string)<br/>    name         = optional(string)<br/>    display_name = optional(string)<br/>    description  = optional(string)<br/>    roles        = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_user_roles"></a> [user\_roles](#input\_user\_roles) | Map of roles for individual users | `map(list(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_roles"></a> [group\_roles](#output\_group\_roles) | n/a |
| <a name="output_network_viewers"></a> [network\_viewers](#output\_network\_viewers) | n/a |
| <a name="output_service_accounts"></a> [service\_accounts](#output\_service\_accounts) | n/a |
| <a name="output_user_roles"></a> [user\_roles](#output\_user\_roles) | n/a |
<!-- END_TF_DOCS -->