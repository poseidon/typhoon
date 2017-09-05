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

# Calico BGP and IPIP
# https://docs.projectcalico.org/v2.5/reference/public-cloud/gce
resource "google_compute_firewall" "allow-calico" {
  count = "${var.networking == "calico" ? 1 : 0}"

  name    = "${var.cluster_name}-allow-calico"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = ["179"]
  }

  allow {
    protocol = "ipip"
  }

  source_ranges = ["10.0.0.0/8"]
}
