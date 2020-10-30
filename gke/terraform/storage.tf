# Google Storage Bucket
# Created if not specified
resource "google_storage_bucket" "bucket" {
  name  = local.unique_id
  count = local.create_bucket ? 1 : 0

  bucket_policy_only = true
}

# Add Manager Service Account as a bucket admin
resource "google_storage_bucket_iam_member" "manager_access" {
  bucket = local.bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.manager.email}"
}

# Add Agent Service Account as a bucket admin
resource "google_storage_bucket_iam_member" "agent_access" {
  bucket = local.bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.agent.email}"
}
