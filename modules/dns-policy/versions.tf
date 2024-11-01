terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.49, < 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4"
    }
  }
}
