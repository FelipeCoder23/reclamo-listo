output "api_url" {
  description = "Private api URL (IAM-protected)."
  value       = google_cloud_run_v2_service.api.uri
}

output "web_url" {
  description = "Public web URL."
  value       = google_cloud_run_v2_service.web.uri
}

output "artifact_registry" {
  description = "Docker repository path for image pushes."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.images.repository_id}"
}

output "api_service_account" {
  value = google_service_account.api.email
}

output "web_service_account" {
  value = google_service_account.web.email
}
