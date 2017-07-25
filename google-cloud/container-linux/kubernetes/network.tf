resource "google_compute_network" "network" {
  name                    = "${var.cluster_name}"
  description             = "Network for the ${var.cluster_name} cluster"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow-ingress" {
  name    = "${var.cluster_name}-allow-ingress"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.cluster_name}-allow-ssh"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "${var.cluster_name}-allow-internal"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_ranges = ["10.0.0.0/8"]
}
