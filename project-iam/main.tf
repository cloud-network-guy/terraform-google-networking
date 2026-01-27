# Healthchecks
locals {
  project    = lower(trimspace(coalesce(var.project_id, var.project)))
  org_domain = lower(trimspace(coalesce(var.org_domain, "example.org")))
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

# Create service accounts
resource "google_service_account" "default" {
  for_each     = local.service_accounts
  project      = local.project
  account_id   = each.value.account_id
  description  = each.value.description
  display_name = each.value.display_name
}

# Add roles for each Service Account
resource "google_project_iam_member" "default" {
  for_each = { for v in local.service_account_roles : "${v.account_key}/${v.role}" => v }
  project  = local.project
  member   = google_service_account.default[each.value.account_key].member
  role     = each.value.role
}

# Assign roles to certain groups
locals {
  _group_roles = [for group, roles in var.group_roles :
    {
      group = lower(strcontains(group, "@") ? group : "${group}@${local.org_domain}")
      roles = [for role in coalesce(roles, []) : startswith(role, "roles/") ? role : "roles/${role}"]
    }
  ]
  group_roles = flatten([for group_role in local._group_roles :
    [for role in group_role.roles :
      {
        member = group_role.group
        role   = role
      }
    ]
  ])
  groups = toset([for group_role in local.group_roles : group_role.member])
}
resource "google_project_iam_member" "group_roles" {
  for_each = { for v in local.group_roles : "${v.member}/${v.role}" => v }
  project  = local.project
  member   = "group:${each.value.member}"
  role     = each.value.role
}

# Assign roles to individual users
locals {
  _user_roles = [for user, roles in var.user_roles :
    {
      group = lower(strcontains(user, "@") ? user : "${user}@${local.org_domain}")
      roles = [for role in coalesce(roles, []) : startswith(role, "roles/") ? role : "roles/${role}"]
    }
  ]
  user_roles = flatten([for user_role in local._user_roles :
    [for role in user_role.roles :
      {
        member = user_role.group
        role   = role
      }
    ]
  ])
  users = toset([for user_role in local.user_roles : user_role.member])
}
resource "google_project_iam_member" "user_roles" {
  for_each = { for v in local.user_roles : "${v.member}/${v.role}" => v }
  project  = local.project
  member   = "user:${each.value.member}"
  role     = each.value.role
}

locals {
  network_viewers = [for i, v in var.network_viewers :
    endswith(v, ".iam.gserviceaccount.com") ? v : "${v}.iam.gserviceaccount.com"
  ]
}
resource "google_project_iam_member" "network_viewers" {
  for_each = toset(local.network_viewers)
  project  = local.project
  member   = "serviceAccount:${each.value}"
  role     = "roles/compute.networkViewer"
}
