provider "google" {
  project = "ensai-2026"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-id2363"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "subnet-id2363"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_http_8000" {
  name    = "allow-http-8000"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8000"]
  }

  source_ranges = ["0.0.0.0/0"] 
}

resource "google_compute_instance" "api_vm" {
  name         = "vm-id2363"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet.id
    access_config {
    }
  }

  # Script de démarrage (Startup Script)
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker

    docker pull europe-docker.pkg.dev/ensai-2026/christophe/api-id2363:latest
    docker run -d -p 8000:8000 europe-docker.pkg.dev/ensai-2026/christophe/api-id2363:latest

  EOT

  service_account {
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only"]
  }
}

output "vm_public_ip" {
  value = google_compute_instance.api_vm.network_interface[0].access_config[0].nat_ip
}