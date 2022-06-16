resource "google_compute_firewall" "media-wiki" {
  project     = var.project.project
  name        = "internal-wiki"
  network     = var.networking.network
  description = "Creates firewall rule for internal media wiki access"
  allow {
    protocol  = var.firewall-rules-protocol.wiki
    ports     = [var.firewall-rules-port.wiki]
  }
  target_tags = [var.tags.store]
  source_ranges = [var.firewall-rules-source-range.wiki]
  depends_on = [google_compute_network.vpc_network]
}
resource "google_compute_firewall" "ssh" {
  project     = var.project.project
  name        = "internal-ssh"
  network     = var.networking.network
  description = "Creates firewall rule for internal ssh access"
  allow {
    protocol  = var.firewall-rules-protocol.ssh
    ports     = [var.firewall-rules-port.in-ssh]
  }
  source_ranges = [var.firewall-rules-source-range.in-ssh]
  depends_on = [google_compute_network.vpc_network]
}
resource "google_compute_firewall" "external-vpn" {
  project     = var.project.project
  name        = "external-vpn"
  network     = var.networking.network
  description = "Creates firewall rule for external vpn access"
  allow {
    protocol  = var.firewall-rules-protocol.vpn
    ports     = [var.firewall-rules-port.vpn]
  }
  target_tags = [var.tags.vpn]
  source_ranges = [var.firewall-rules-source-range.vpn]
  depends_on = [google_compute_network.vpc_network]
}
resource "google_compute_firewall" "external-ssh-cloud-vpn" {
  project     = var.project.project
  name        = "external-ssh"
  network     = var.networking.network
  description = "Creates firewall rule for external ssh access"
  allow {
    protocol  = var.firewall-rules-protocol.ssh
    ports     = [var.firewall-rules-port.ex-ssh]
  }
  target_tags = [var.tags.vpn]
  source_ranges = [var.firewall-rules-source-range.vpn]
  depends_on = [google_compute_network.vpc_network]
}
