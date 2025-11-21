output "service_accounts" {
  value = { for k, v in local.service_accounts :
    k => {
      id     = google_service_account.default[k].id
      email  = google_service_account.default[k].email
      member = google_service_account.default[k].member
    }
  }
}
