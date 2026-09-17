terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.14.0, < 8.0.0"
    }
  }
  provider_meta "google" {
  }
}
