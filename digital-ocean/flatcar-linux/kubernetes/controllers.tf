locals {
  official_images   = []
  is_official_image = contains(local.official_images, var.os_image)
}

# Controller Instance DNS records
resource "digitalocean_record" "controllers" {
  count = var.controller_count

  # DNS zone where record should be created
  domain = var.dns_zone

  # DNS record (will be prepended to domain)
  name = var.cluster_name
  type = "A"
  ttl  = 300

  # IPv4 addresses of controllers
  value = digitalocean_droplet.controllers.*.ipv4_address[count.index]
}

# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "digitalocean_record" "etcds" {
  count = var.controller_count

  # DNS zone where record should be created
  domain = var.dns_zone

  # DNS record (will be prepended to domain)
  name = "${var.cluster_name}-etcd${count.index}"
  type = "A"
  ttl  = 300

  # private IPv4 address for etcd
  value = digitalocean_droplet.controllers.*.ipv4_address_private[count.index]
}

# Controller droplet instances
resource "digitalocean_droplet" "controllers" {
  count = var.controller_count

  name   = "${var.cluster_name}-controller-${count.index}"
  region = var.region

  image = var.os_image
  size  = var.controller_type

  # network
  vpc_uuid = digitalocean_vpc.network.id
  # TODO: Only official DigitalOcean images support IPv6
  ipv6 = false

  user_data = data.ct_config.controllers.*.rendered[count.index]
  ssh_keys  = var.ssh_fingerprints

  tags = [
    digitalocean_tag.controllers.id,
  ]

  lifecycle {
    ignore_changes = [user_data]
  }
}

# Tag to label controllers
resource "digitalocean_tag" "controllers" {
  name = "${var.cluster_name}-controller"
}

# Flatcar Linux controllers
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
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
  })
  strict   = true
  snippets = var.controller_snippets
}
