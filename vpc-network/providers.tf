provider "google" {
  project = var.project_id
}

# Set Quota/Billing Project for Cloud Asset Resource Manager queries
provider "google-beta" {
  project               = var.project_id
  billing_project       = var.project_id
  user_project_override = true
}
