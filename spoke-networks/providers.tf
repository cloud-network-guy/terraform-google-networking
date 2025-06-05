provider "google" {
  project = local.project
  region  = local.region
}

provider "google-beta" {
  project               = local.project
  billing_project       = local.project
  user_project_override = true
}
