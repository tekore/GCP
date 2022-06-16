//For static external IP's
resource "google_compute_address" "static" {
  name = "ipv4-address"
}

//Create the VPC
resource "google_compute_network" "vpc_network" {
  project                 = var.project.project
  name                    = var.networking.network
  auto_create_subnetworks = false
  mtu                     = var.networking.mtu
}

//Create main network for VPC
resource "google_compute_subnetwork" "main_network" {
  name          = "main"
  ip_cidr_range = var.networking.ip-range-internal
  region        = var.project.region
  network       = google_compute_network.vpc_network.id
}

//Reserve internal static IP's
resource "google_compute_address" "cloud_vpn" {
  subnetwork = "main"
  name = var.tags.vpn
  address_type  = "INTERNAL"
  address       = var.static-ip.vpn
  depends_on = [google_compute_subnetwork.main_network]
}
resource "google_compute_address" "cloud_store" {
  subnetwork = "main"
  name = var.tags.store
  address_type  = "INTERNAL"
  address       = var.static-ip.store
  depends_on = [google_compute_subnetwork.main_network]
}

//Create the cloud router
resource "google_compute_router" "router" {
  name    = var.networking-router.router-name
  #network = google_compute_network.router.name
  network = google_compute_network.vpc_network.name
  bgp {
    asn               = var.networking-router.asn
    advertise_mode    = var.networking-router.advertise_mode
    advertised_groups = [var.networking-router.advertised_group]
  }
}

//Create cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = var.networking-nat.name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = var.networking-nat.nat-ip-option
  source_subnetwork_ip_ranges_to_nat = var.networking-nat.source-range-to-nat

  log_config {
    enable = true
    filter = var.networking-nat.log-filter
  }
}

//Create VPC routes
resource "google_compute_route" "vpn-tunnel-route" {
  name        = "vpn-tunnel-route"
  dest_range  = var.networking.ip-range-tunnel
  network     = google_compute_network.vpc_network.name
  next_hop_ip = var.static-ip.vpn
  priority    = 1
  depends_on = [google_compute_subnetwork.main_network]
}
