terraform {
  required_version = ">= 1.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.5"
    }
  }

  # State lives in a versioned bucket created by hand during bootstrap (see README.md).
  backend "gcs" {
    bucket = "reclamo-listo-tfstate"
    prefix = "prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
