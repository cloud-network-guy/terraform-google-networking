# Set Quota/Billing Project for Cloud Asset Resource Manager queries
provider "google-beta" {
  project               = var.host_project_id
  billing_project       = var.host_project_id
  user_project_override = true
}