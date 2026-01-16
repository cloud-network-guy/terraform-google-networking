provider "google" {
  project = local.host_project_id
}

# Set Quota/Billing Project for Cloud Asset Resource Manager queries
provider "google-beta" {
  project               = local.host_project_id
  billing_project       = local.host_project_id
  user_project_override = true
}

