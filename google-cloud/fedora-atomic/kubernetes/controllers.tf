# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "google_dns_record_set" "etcds" {
  count = "${var.controller_count}"

  # DNS Zone name where record should be created
  managed_zone = "${var.dns_zone_name}"

  # DNS record
  name = "${format("%s-etcd%d.%s.", var.cluster_name, count.index,  var.dns_zone)}"
  type = "A"
  ttl  = 300

  # private IPv4 address for etcd
  rrdatas = ["${element(google_compute_instance.controllers.*.network_interface.0.address, count.index)}"]
}

# Zones in the region
data "google_compute_zones" "all" {
  region = "${var.region}"
}

locals {
  # TCP proxy load balancers require a fixed number of zonal backends. Spread
  # controllers over up to 3 zones, since all GCP regions have at least 3.
  zones = "${slice(data.google_compute_zones.all.names, 0, 3)}"

  controllers_ipv4_public = ["${google_compute_instance.controllers.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

# Controller instances
resource "google_compute_instance" "controllers" {
  count = "${var.controller_count}"

  name         = "${var.cluster_name}-controller-${count.index}"
  zone         = "${element(local.zones, count.index)}"
  machine_type = "${var.controller_type}"

  metadata {
    user-data = "${element(data.template_file.controller-cloudinit.*.rendered, count.index)}"
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.os_image}"
      size  = "${var.disk_size}"
    }
  }

  network_interface {
    network = "${google_compute_network.network.name}"

    # Ephemeral external IP
    access_config = {}
  }

  can_ip_forward = true
  tags           = ["${var.cluster_name}-controller"]
}

# Controller Cloud-Init
data "template_file" "controller-cloudinit" {
  count = "${var.controller_count}"

  template = "${file("${path.module}/cloudinit/controller.yaml.tmpl")}"

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = "${join(",", data.template_file.etcds.*.rendered)}"

    kubeconfig            = "${indent(6, module.bootkube.kubeconfig)}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "template_file" "etcds" {
  count    = "${var.controller_count}"
  template = "etcd$${index}=https://$${cluster_name}-etcd$${index}.$${dns_zone}:2380"

  vars {
    index        = "${count.index}"
    cluster_name = "${var.cluster_name}"
    dns_zone     = "${var.dns_zone}"
  }
}
