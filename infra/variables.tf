variable "project_id" {
  description = "GCP project ID."
  type        = string
  default     = "reclamo-listo"
}

variable "region" {
  description = "Region for Cloud Run, Artifact Registry and Firestore."
  type        = string
  default     = "us-central1"
}

variable "deployer_service_account" {
  description = "Service account assumed by GitHub Actions through Workload Identity Federation (created by hand in bootstrap)."
  type        = string
  default     = "github-deployer@reclamo-listo.iam.gserviceaccount.com"
}

# Cloud Run needs an image to exist. Services start with Google's public hello image;
# deploy.yml replaces it with the real one and Terraform ignores that attribute afterwards.
variable "placeholder_image" {
  description = "Image used when a Cloud Run service is first created."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}
