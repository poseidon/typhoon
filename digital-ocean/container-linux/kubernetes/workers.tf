# Worker DNS records
resource "digitalocean_record" "workers-record-a" {
  count = "${var.worker_count}"

  # DNS zone where record should be created
  domain = "${var.dns_zone}"

  name  = "${var.cluster_name}-workers"
  type  = "A"
  ttl   = 300
  value = "${element(digitalocean_droplet.workers.*.ipv4_address, count.index)}"
}

resource "digitalocean_record" "workers-record-aaaa" {
  count = "${var.worker_count}"

  # DNS zone where record should be created
  domain = "${var.dns_zone}"

  name  = "${var.cluster_name}-workers"
  type  = "AAAA"
  ttl   = 300
  value = "${element(digitalocean_droplet.workers.*.ipv6_address, count.index)}"
}

# Worker droplet instances
resource "digitalocean_droplet" "workers" {
  count = "${var.worker_count}"

  name   = "${var.cluster_name}-worker-${count.index}"
  region = "${var.region}"

  image = "${var.image}"
  size  = "${var.worker_type}"

  # network
  ipv6               = true
  private_networking = true

  user_data = "${data.ct_config.worker-ignition.rendered}"
  ssh_keys  = ["${var.ssh_fingerprints}"]

  tags = [
    "${digitalocean_tag.workers.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Tag to label workers
resource "digitalocean_tag" "workers" {
  name = "${var.cluster_name}-worker"
}

# Worker Ignition config
data "ct_config" "worker-ignition" {
  content      = "${data.template_file.worker-config.rendered}"
  pretty_print = false
  snippets     = ["${var.worker_clc_snippets}"]
}

# Worker Container Linux config
data "template_file" "worker-config" {
  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars = {
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}
