// GCP Compute instances
resource "google_compute_instance" "cloud-vpn" {
 name = var.name.vpn
 machine_type = var.vm-type.e2
 zone         = var.zone.eu-west2-c
 can_ip_forward = true
 tags = [var.tags.vpn]
 boot_disk {
   initialize_params {
     image = var.image.ubuntu2004
   }
 }
  metadata = {ssh-keys = var.temp-ssh-keys}
  network_interface {
    subnetwork_project = var.gcloud-network.subnetwork_project
    subnetwork = var.gcloud-network.subnetwork
    network = var.gcloud-network.network
    network_ip = google_compute_address.cloud_vpn.address
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}

resource "google_compute_instance" "cloud-store" {
 name = var.name.store
 machine_type = var.vm-type.e2
 zone         = var.zone.eu-west2-c
 tags = [var.tags.store]
 boot_disk {
   initialize_params {
     image = var.image.ubuntu2004
   }
 }
 network_interface {
   subnetwork_project = var.gcloud-network.subnetwork_project
   subnetwork = var.gcloud-network.subnetwork
   network = var.gcloud-network.network
   network_ip = google_compute_address.cloud_store.address
 }
}

resource "null_resource" "rm-known_hosts" {
 provisioner "local-exec" {
   command = "rm -f /home/<REDACTED>/.ssh/known_hosts"
 }
}

resource "null_resource" "ansible-cloud-vpn" { 
 provisioner "local-exec" {
   command = var.ansible-playbooks.vpn
 }
 depends_on = [google_compute_instance.cloud-vpn]
}

resource "null_resource" "ansible-cloud-store" {
 provisioner "local-exec" {
   command = var.ansible-playbooks.store
 }
 depends_on = [google_compute_instance.cloud-vpn, google_compute_instance.cloud-store, null_resource.ansible-cloud-vpn]
}

output "VPN_IP" {
  value = google_compute_instance.cloud-vpn.network_interface[0].access_config[0].nat_ip
}
