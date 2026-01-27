output "service_accounts" {
  value = { for k, v in local.service_accounts :
    k => {
      id     = google_service_account.default[k].id
      email  = google_service_account.default[k].email
      member = google_service_account.default[k].member
    }
  }
}
output "group_roles" {
  value = { for group in local.groups :
    group => [for i, v in local.group_roles :
      google_project_iam_member.group_roles["${v.member}/${v.role}"].role if group == v.member
    ]
  }
}
output "user_roles" {
  value = { for user in local.users :
    user => [for i, v in local.user_roles :
      google_project_iam_member.user_roles["${v.member}/${v.role}"].role if user == v.member
    ]
  }
}
output "network_viewers" {
  value = [for i, v in toset(local.network_viewers) :
    google_project_iam_member.network_viewers[v].member
  ]
}
