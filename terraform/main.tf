# --- VPC Network ---
resource "google_compute_network" "vpc" {
  name                    = "${var.env_name}-vpc" # spiral-c2-vpc
  auto_create_subnetworks = false
}

# --- Subnets ---
resource "google_compute_subnetwork" "private" {
  name    = "${var.env_name}-private-subnet" # spiral-c2-private-subnet
  region  = var.region
  network = google_compute_network.vpc.id

  ip_cidr_range = "10.0.0.0/20"

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }

  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }

  private_ip_google_access = true
}

# --- Router & NAT ---
resource "google_compute_router" "router" {
  name    = "${var.env_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.env_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# --- Firewall ---
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.env_name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}