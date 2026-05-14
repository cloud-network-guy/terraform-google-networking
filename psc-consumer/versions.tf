terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.16.0, < 8.0.0"
    }
  }
  provider_meta "google" {
    user_agent = [
      "github.com/cloud-network-guy/terraform-google-networking/psc-consumer"
    ]
  }
}
