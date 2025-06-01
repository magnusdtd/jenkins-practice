terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
  required_version = "1.12.1"
}

provider "google" {
  credentials = var.credentials
  project     = var.project_id
  region      = var.region
}

// Google Kubernetes Engine
resource "google_container_cluster" "primary" {
  name               = "${var.project_id}-gke"
  location           = var.region
  enable_autopilot   = var.GKE_enable_autopilot
  initial_node_count = var.GKE_initial_node_count
  deletion_protection = false

  node_config {
    machine_type = var.machine_type_instance
    disk_size_gb = var.machine_disk_size
  }
}

# Google compute instance
resource "google_compute_instance" "instance_jenkins" {
  name         = var.instance_name
  machine_type = var.machine_type_instance
  zone         = var.zone
  tags         = [var.firewall_name]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network = var.network_name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.user_name}:${file("${path.module}/../secrets/jenkins_key.pub")}"
  }

  // save the public key in a local variable for ansible setup jenkins
  provisioner "local-exec" {
    command = <<-EOT
      echo "[jenkins]" > ${path.module}/../ansible/inventory/inventory.ini
      echo "${self.network_interface[0].access_config[0].nat_ip} ansible_user=${var.user_name} ansible_ssh_private_key_file=${path.module}/../secrets/jenkins_key" >> ${path.module}/../ansible/inventory/inventory.ini
    EOT
  }
}

resource "google_compute_firewall" "firewall_jenkins" {
  name        = var.firewall_name
  network     = var.network_name
  target_tags = [var.firewall_name]

  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }

  source_ranges = var.source_ranges
}
