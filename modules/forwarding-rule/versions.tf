terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.16.0, < 8.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
  }
}
