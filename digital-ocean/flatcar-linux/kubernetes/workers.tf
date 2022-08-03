# Worker DNS records
resource "digitalocean_record" "workers-record-a" {
  count = var.worker_count

  # DNS zone where record should be created
  domain = var.dns_zone

  name  = "${var.cluster_name}-workers"
  type  = "A"
  ttl   = 300
  value = digitalocean_droplet.workers.*.ipv4_address[count.index]
}

resource "digitalocean_record" "workers-record-aaaa" {
  # only official DigitalOcean images support IPv6
  count = local.is_official_image ? var.worker_count : 0

  # DNS zone where record should be created
  domain = var.dns_zone

  name  = "${var.cluster_name}-workers"
  type  = "AAAA"
  ttl   = 300
  value = digitalocean_droplet.workers.*.ipv6_address[count.index]
}

# Worker droplet instances
resource "digitalocean_droplet" "workers" {
  count = var.worker_count

  name   = "${var.cluster_name}-worker-${count.index}"
  region = var.region

  image = var.os_image
  size  = var.worker_type

  # network
  vpc_uuid = digitalocean_vpc.network.id
  # only official DigitalOcean images support IPv6
  ipv6 = local.is_official_image

  user_data = data.ct_config.worker.rendered
  ssh_keys  = var.ssh_fingerprints

  tags = [
    digitalocean_tag.workers.id,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Tag to label workers
resource "digitalocean_tag" "workers" {
  name = "${var.cluster_name}-worker"
}

# Flatcar Linux worker
data "ct_config" "worker" {
  content = templatefile("${path.module}/butane/worker.yaml", {
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
  })
  strict   = true
  snippets = var.worker_snippets
}
