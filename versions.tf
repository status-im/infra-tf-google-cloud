
terraform {
  required_version = "~> 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 3.73.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 2.21.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = " = 1.0.4"
    }
  }
}
