# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "google_dns_record_set" "etcds" {
  count = var.controller_count

  # DNS Zone name where record should be created
  managed_zone = var.dns_zone_name

  # DNS record
  name = format("%s-etcd%d.%s.", var.cluster_name, count.index, var.dns_zone)
  type = "A"
  ttl  = 300

  # private IPv4 address for etcd
  rrdatas = [google_compute_instance.controllers.*.network_interface.0.network_ip[count.index]]
}

# Zones in the region
data "google_compute_zones" "all" {
  region = var.region
}

locals {
  zones = data.google_compute_zones.all.names

  controllers_ipv4_public = google_compute_instance.controllers.*.network_interface.0.access_config.0.nat_ip
}

# Controller instances
resource "google_compute_instance" "controllers" {
  count = var.controller_count

  name = "${var.cluster_name}-controller-${count.index}"
  # use a zone in the region and wrap around (e.g. controllers > zones)
  zone         = element(local.zones, count.index)
  machine_type = var.controller_type

  metadata = {
    user-data = data.ct_config.controllers.*.rendered[count.index]
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      image = data.google_compute_image.fedora-coreos.self_link
      size  = var.disk_size
    }
  }

  network_interface {
    network = google_compute_network.network.name

    # Ephemeral external IP
    access_config {
    }
  }

  can_ip_forward = true
  allow_stopping_for_update = true
  tags           = ["${var.cluster_name}-controller"]

  lifecycle {
    ignore_changes = [
      metadata,
      boot_disk[0].initialize_params
    ]
  }
}

# Fedora CoreOS controllers
data "ct_config" "controllers" {
  count = var.controller_count
  content = templatefile("${path.module}/butane/controller.yaml", {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = join(",", [
      for i in range(var.controller_count) : "etcd${i}=https://${var.cluster_name}-etcd${i}.${var.dns_zone}:2380"
    ])
    kubeconfig             = indent(10, module.bootstrap.kubeconfig-kubelet)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
  })
  strict   = true
  snippets = var.controller_snippets
}
