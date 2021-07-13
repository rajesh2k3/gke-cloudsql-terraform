# iam.tf
# Provisions all IAM related resources for this project.

# Create the GKE service account
resource "google_service_account" "gke-sa" {
  project      = var.project_id
  account_id   = "gke-cluster-minimal-sa"
  display_name = "Minimal service account for GKE cluster"
}

# Add the service account to the project
resource "google_project_iam_member" "service-account" {
  count   = length(var.service_account_iam_roles)
  project = var.project_id
  role    = element(var.service_account_iam_roles, count.index)
  member  = "serviceAccount:${google_service_account.gke-sa.email}"
}

# Add user-specified roles
resource "google_project_iam_member" "service-account-custom" {
  count   = length(var.service_account_custom_iam_roles)
  project = var.project_id
  role    = element(var.service_account_custom_iam_roles, count.index)
  member  = "serviceAccount:${google_service_account.gke-sa.email}"
}

# Create Google Service Account (GSA) for postgres access
resource "google_service_account" "access-postgres" {
  project      = var.project_id
  account_id   = "${var.project_id}-pg-gsa"
}

# Attach cloudsql access permissions to the GSA
resource "google_project_iam_binding" "access-postgres" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.access-postgres.email}"
  ]
}

# Create an IAM policy that allows the k8s SA (KSA) to be a workload identity user
data "google_iam_policy" "access-postgres" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa_name}]"
    ]
  }
}

# Bind the workload identity IAM policy to the GSA
resource "google_service_account_iam_policy" "access-postgres" {
  service_account_id = google_service_account.access-postgres.name
  policy_data        = data.google_iam_policy.access-postgres.policy_data
}