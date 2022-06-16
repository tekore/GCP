// Define GCP provider
provider "google" {
 credentials = file(var.project.creds)
 project     = var.project.project
 region      = var.project.region
}

// Add GCP project wide SSH key
resource "google_compute_project_metadata" "my_ssh_key" {
  metadata = {ssh-keys = var.project.project-ssh-key}
}
