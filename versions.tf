
terraform {
  required_version = "~> 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 4.15.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 3.26.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = " = 1.0.4"
    }
  }
}
