provider "google" {
  project = local.project
}

# Set Quota/Billing Project for Cloud Asset Resource Manager queries
provider "google-beta" {
  project               = local.project
  billing_project       = local.project
  user_project_override = true
}
