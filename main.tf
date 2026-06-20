provider "google" {
  project     = "project-f58454be-54a8-4e89-a39"
  region      = "us-east4"
  zone        = "us-east4-a"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vibs-terra-vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

############################# subnet ################

resource "google_compute_subnetwork" "subnet" {
  name          = "vibs-terra-subnet"
  ip_cidr_range = "192.168.30.0/26"
  region        = "us-east4"
  network       = google_compute_network.vpc_network.id

}

############################# firewall ################

resource "google_compute_firewall" "firewall" {
  name    = "vibs-terra-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges      = ["192.168.30.0/26"]
  destination_ranges = ["192.168.10.0/24"]
}

resource "google_compute_firewall" "firewall2" {
  name    = "vibs-terra-firewall-for-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

############################# cloudnat ################

resource "google_compute_router" "router" {

  name    = "vibs-terra-router"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "cloudnat" {

  name                               = "vibs-terra-cloudnat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

############################# VM ################

resource "google_compute_instance" "terra-vm" {
  name         = "vibs-terra-vm"
  machine_type = "e2-medium"
  zone         = "us-east4-a"

  tags = ["test", "terraform"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 15
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = file("apache.sh")
}