terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }

  required_version = ">= 0.12"
}

provider "google" {
  project     = var.GOOGLE_PROJECT
  region      = var.GOOGLE_REGION
  credentials = var.GOOGLE_CREDENTIALS
}
