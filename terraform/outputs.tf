# outputs.tf
# Defines all the relevant outputs for the deployment.

output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "kubernetes_namespace" {
  value = var.k8s_namespace
  description = "k8s namespace used for deployment"
}

# Used when setting up the GKE cluster to talk to Postgres.
output "postgres_instance" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.name
}

# Full connection string for the Postgres DB
output "postgres_instance_connection_name" {
    value = google_sql_database_instance.postgres.connection_name
    description = "Cloud SQL Instance Connection Name"
}

output "cloud_sql_instance_service_account" {
    value = google_sql_database_instance.postgres.service_account_email_address
    description = "Cloud SQL Instance Service Account"
}

# Postgres DB name.
output "postgres_db_name" {
  description = "Postgres database name"
  value = google_sql_database.database.name
}

# Postgres DB username.
output "postgres_user" {
  description = "The Cloud SQL Instance User name"
  value       = google_sql_user.postgres-user.name
}

# Postgres DB password.
output "postgres_pass" {
  sensitive   = true
  description = "The Cloud SQL Instance Password"
  value       = google_sql_user.postgres-user.password
}

# Current GCP project
output "gcp_serviceaccount" {
  description = "The email/name of the GCP Service Account used for cloudsql-postgres authentication"
  value       = google_service_account.access-postgres.email
}

output "get_credentials" {
  description = "Gcloud get-credentials command"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --project ${var.project_id} --zone ${var.zone}"
}