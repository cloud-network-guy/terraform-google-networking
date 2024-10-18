terraform {
  required_version = ">= 1.3.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.49, < 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
