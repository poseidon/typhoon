resource "digitalocean_firewall" "rules" {
  name = "${var.cluster_name}"

  tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]

  # allow ssh, internal flannel, internal node-exporter, internal kubelet
  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol    = "udp"
      port_range  = "8472"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "9100"
      source_tags = ["${digitalocean_tag.workers.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "10250"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}"]
    },
  ]

  # allow all outbound traffic
  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_firewall" "controllers" {
  name = "${var.cluster_name}-controllers"

  tags = ["${var.cluster_name}-controller"]

  # etcd, kube-apiserver, kubelet
  inbound_rule = [
    {
      protocol    = "tcp"
      port_range  = "2379-2380"
      source_tags = ["${digitalocean_tag.controllers.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "2381"
      source_tags = ["${digitalocean_tag.workers.name}"]
    },
    {
      protocol         = "tcp"
      port_range       = "6443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_firewall" "workers" {
  name = "${var.cluster_name}-workers"

  tags = ["${var.cluster_name}-worker"]

  # allow HTTP/HTTPS ingress
  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "10254"
      source_addresses = ["0.0.0.0/0"]
    },
  ]
}
