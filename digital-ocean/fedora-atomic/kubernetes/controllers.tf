# Controller Instance DNS records
resource "digitalocean_record" "controllers" {
  count = "${var.controller_count}"

  # DNS zone where record should be created
  domain = "${var.dns_zone}"

  # DNS record (will be prepended to domain)
  name = "${var.cluster_name}"
  type = "A"
  ttl  = 300

  # IPv4 addresses of controllers
  value = "${element(digitalocean_droplet.controllers.*.ipv4_address, count.index)}"
}

# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "digitalocean_record" "etcds" {
  count = "${var.controller_count}"

  # DNS zone where record should be created
  domain = "${var.dns_zone}"

  # DNS record (will be prepended to domain)
  name = "${var.cluster_name}-etcd${count.index}"
  type = "A"
  ttl  = 300

  # private IPv4 address for etcd
  value = "${element(digitalocean_droplet.controllers.*.ipv4_address_private, count.index)}"
}

# Controller droplet instances
resource "digitalocean_droplet" "controllers" {
  count = "${var.controller_count}"

  name   = "${var.cluster_name}-controller-${count.index}"
  region = "${var.region}"

  image = "${var.image}"
  size  = "${var.controller_type}"

  # network
  ipv6               = true
  private_networking = true

  user_data = "${element(data.template_file.controller-cloudinit.*.rendered, count.index)}"
  ssh_keys  = ["${var.ssh_fingerprints}"]

  tags = [
    "${digitalocean_tag.controllers.id}",
  ]
}

# Tag to label controllers
resource "digitalocean_tag" "controllers" {
  name = "${var.cluster_name}-controller"
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
