# Runtime identities. Each Cloud Run service runs as its own account with the minimum roles.
# The deployer account (GitHub Actions) is created by hand in bootstrap and is not managed here.

resource "google_service_account" "api" {
  account_id   = "run-api"
  display_name = "Cloud Run: api"
}

resource "google_service_account" "web" {
  account_id   = "run-web"
  display_name = "Cloud Run: web"
}

# api reads and writes usage counters in Firestore.
resource "google_project_iam_member" "api_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = google_service_account.api.member
}

# The deployer must be allowed to deploy services that run as these accounts.
resource "google_service_account_iam_member" "deployer_acts_as_api" {
  service_account_id = google_service_account.api.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.deployer_service_account}"
}

resource "google_service_account_iam_member" "deployer_acts_as_web" {
  service_account_id = google_service_account.web.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.deployer_service_account}"
}
