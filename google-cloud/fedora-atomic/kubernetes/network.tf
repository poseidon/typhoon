resource "google_compute_network" "network" {
  name                    = "${var.cluster_name}"
  description             = "Network for the ${var.cluster_name} cluster"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.cluster_name}-allow-ssh"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
}

resource "google_compute_firewall" "allow-apiserver" {
  name    = "${var.cluster_name}-allow-apiserver"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [443]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.cluster_name}-controller"]
}

resource "google_compute_firewall" "allow-ingress" {
  name    = "${var.cluster_name}-allow-ingress"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [80, 443]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.cluster_name}-worker"]
}

resource "google_compute_firewall" "internal-etcd" {
  name    = "${var.cluster_name}-internal-etcd"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [2380]
  }

  source_tags = ["${var.cluster_name}-controller"]
  target_tags = ["${var.cluster_name}-controller"]
}

# Allow Prometheus to scrape etcd metrics
resource "google_compute_firewall" "internal-etcd-metrics" {
  name    = "${var.cluster_name}-internal-etcd-metrics"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [2381]
  }

  source_tags = ["${var.cluster_name}-worker"]
  target_tags = ["${var.cluster_name}-controller"]
}

# Calico BGP and IPIP
# https://docs.projectcalico.org/v2.5/reference/public-cloud/gce
resource "google_compute_firewall" "internal-calico" {
  count = "${var.networking == "calico" ? 1 : 0}"

  name    = "${var.cluster_name}-internal-calico"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = ["179"]
  }

  allow {
    protocol = "ipip"
  }

  source_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
  target_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
}

# flannel
resource "google_compute_firewall" "internal-flannel" {
  count = "${var.networking == "flannel" ? 1 : 0}"

  name    = "${var.cluster_name}-internal-flannel"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "udp"
    ports    = [8472]
  }

  source_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
  target_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
}

# Allow Prometheus to scrape node-exporter daemonset
resource "google_compute_firewall" "internal-node-exporter" {
  name    = "${var.cluster_name}-internal-node-exporter"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [9100]
  }

  source_tags = ["${var.cluster_name}-worker"]
  target_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
}

# kubelet API to allow kubectl exec and log
resource "google_compute_firewall" "internal-kubelet" {
  name    = "${var.cluster_name}-internal-kubelet"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [10250]
  }

  source_tags = ["${var.cluster_name}-controller"]
  target_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
}

resource "google_compute_firewall" "internal-kubelet-readonly" {
  name    = "${var.cluster_name}-internal-kubelet-readonly"
  network = "${google_compute_network.network.name}"

  allow {
    protocol = "tcp"
    ports    = [10255]
  }

  source_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
  target_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
}
