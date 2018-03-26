# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "google_dns_record_set" "etcds" {
  count = "${var.count}"

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

# Controller instances
resource "google_compute_instance" "controllers" {
  count = "${var.count}"

  name         = "${var.cluster_name}-controller-${count.index}"
  zone         = "${element(data.google_compute_zones.all.names, count.index)}"
  machine_type = "${var.machine_type}"

  metadata {
    user-data = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.os_image}"
      size  = "${var.disk_size}"
    }
  }

  network_interface {
    network = "${var.network}"

    # Ephemeral external IP
    access_config = {}
  }

  can_ip_forward = true
  tags           = ["${var.cluster_name}-controller"]
}

# Controller Container Linux Config
data "template_file" "controller_config" {
  count = "${var.count}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = "${join(",", formatlist("%s=https://%s:2380", null_resource.repeat.*.triggers.name, null_resource.repeat.*.triggers.domain))}"

    kubeconfig            = "${indent(10, var.kubeconfig)}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

# Horrible hack to generate a Terraform list of a desired length without dependencies.
# Ideal ${repeat("etcd", 3) -> ["etcd", "etcd", "etcd"]}
resource null_resource "repeat" {
  count = "${var.count}"

  triggers {
    name   = "etcd${count.index}"
    domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
  }
}

data "ct_config" "controller_ign" {
  count        = "${var.count}"
  content      = "${element(data.template_file.controller_config.*.rendered, count.index)}"
  pretty_print = false
  snippets     = ["${var.clc_snippets}"]
}
