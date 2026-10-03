# One Docker repository for both images (api and web), tagged by commit SHA.
# The cleanup policy keeps storage cost flat: at most 10 recent versions, nothing older than 30 days.
resource "google_artifact_registry_repository" "images" {
  repository_id = "reclamo-listo"
  location      = var.region
  format        = "DOCKER"
  description   = "Container images for the api and web services"

  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"
    condition {
      older_than = "2592000s" # 30 days
    }
  }

  depends_on = [google_project_service.apis]
}
