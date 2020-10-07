
terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 3.42.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 2.10.1"
    }
    ansible = {
      source  = "nbering/ansible"
      version = " = 1.0.4"
    }
  }
}
