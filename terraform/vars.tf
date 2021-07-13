# vars.tf
# Defines project-specific variables that can be injected into other
# HCL files using "${var.var_name}" syntax.

# ==[ Project variables ]================================================

# Required values to be set in terraform.tfvars

variable "project_id" {
  type = string
  description = "Google Cloud project ID (not name)"
  default = "stately-minutia-318001"
}

variable "region" {
  description = "The region to host the cluster in"
  default = "us-central1"
}

variable "zone" {
  description = "The zone to host the cloud sql database"
  default = "us-central1-b"
}

# ==[ Optional variables ]======================================================

# Optional values that can be overridden or appended to if desired.

variable "gke_num_nodes" {
  description = "number of gke nodes"
  default     = 1
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace to use for the deployment and workload identity binding"
  default     = "default"
}

variable "k8s_sa_name" {
  type        = string
  description = "The k8s service account name to use for the deployment and workload identity binding"
  default     = "postgres-ksa"
}

variable "db_name" {
  type        = string
  description = "Name of the DB"
  default     = "deloitte-challenge-test-database"
}

variable "db_username" {
  type        = string
  description = "The name for the DB connection"
  default     = "pgadmin@postgres.com"
}

variable "db_password" {
  type = string
  description = "The password of postgres database user"
  sensitive = true
}

variable "service_account_iam_roles" {
  type = list
  description = "List of the default IAM roles to attach to the service account on the GKE Nodes."
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ]
}

variable "service_account_custom_iam_roles" {
  type = list
  description = "List of arbitrary additional IAM roles to attach to the service account on the GKE nodes."
  default = []
}

variable "project_services" {
  type = list
  description = "The GCP APIs that should be enabled in this project."
  default = [
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "securetoken.googleapis.com",
  ]
}