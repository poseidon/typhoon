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

  user_data = "${data.ct_config.controller_ign.rendered}"
  ssh_keys  = "${var.ssh_fingerprints}"

  tags = [
    "${digitalocean_tag.controllers.id}",
  ]
}

# Tag to label controllers
resource "digitalocean_tag" "controllers" {
  name = "${var.cluster_name}-controller"
}

# Controller Container Linux Config
data "template_file" "controller_config" {
  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    k8s_dns_service_ip      = "${cidrhost(var.service_cidr, 10)}"
    k8s_etcd_service_ip     = "${cidrhost(var.service_cidr, 15)}"
  }
}

data "ct_config" "controller_ign" {
  content      = "${data.template_file.controller_config.rendered}"
  pretty_print = false
}
