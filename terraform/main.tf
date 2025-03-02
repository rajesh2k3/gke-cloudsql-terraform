# main.tf
# Configures Terraform workspace/provider settings.

terraform {
  required_version = ">= 1.2.4"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.24.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
  }
}

# Enable required services on the project
resource "google_project_service" "service" {
  count   = length(var.project_services)
  project = var.project_id
  service = element(var.project_services, count.index)

  #  Do not disable the service on destroy. On destroy, we are going to
  #  destroy the project, but we need the APIs available to destroy the
  #  underlying resources.
  disable_on_destroy = false
}
