terraform {
  required_version = ">= 1.8.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.12.0, < 7.0.0"
    }
  }
}
