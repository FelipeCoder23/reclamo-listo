# Firestore in Native mode, single region (cheaper than multi-region, enough for counters).
# Only usage counters live here: salted IP hash + day, and the global daily cap. Never the user's story.
resource "google_firestore_database" "default" {
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  # Learning project: allow destroy and recreate. Flip both before there is data worth keeping.
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
  deletion_policy         = "DELETE"

  depends_on = [google_project_service.apis]
}
