terraform {
  required_version = ">= 1.3.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.49, < 5.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}

