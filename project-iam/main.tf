# Healthchecks
locals {
  project = lower(trimspace(coalesce(var.project_id, var.project)))
  service_accounts = { for k, v in var.service_accounts :
    k => {
      account_id   = coalesce(v.account_id, v.name, k)
      description  = v.description != null ? trimspace(v.description) : null
      display_name = v.display_name != null || v.name != null ? trimspace(coalesce(v.display_name, v.name)) : null
      roles        = coalesce(v.roles, [])
    } if v.create
  }
  service_account_roles = flatten([for k, v in local.service_accounts :
    [for r in v.roles :
      {
        account_key = k
        role        = startswith(r, "roles/") ? r : "roles/${r}"
      }
    ]
  ])
}
resource "google_service_account" "default" {
  for_each     = { for k, v in local.service_accounts : k => v }
  project      = local.project
  account_id   = each.value.account_id
  description  = each.value.description
  display_name = each.value.display_name
}

resource "google_project_iam_member" "default" {
  for_each = { for v in local.service_account_roles : "${v.account_key}/${v.role}" => v }
  project  = local.project
  role     = each.value.role
  member   = google_service_account.default[each.value.account_key].member
}
