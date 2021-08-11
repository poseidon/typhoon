# Network VPC
resource "digitalocean_vpc" "network" {
  name        = var.cluster_name
  region      = var.region
  description = "Network for ${var.cluster_name} cluster"
}

resource "digitalocean_firewall" "rules" {
  name = var.cluster_name

  tags = [
    digitalocean_tag.controllers.name,
    digitalocean_tag.workers.name
  ]

  inbound_rule {
    protocol    = "icmp"
    source_tags = [digitalocean_tag.controllers.name, digitalocean_tag.workers.name]
  }

  # allow ssh, internal flannel, internal node-exporter, internal kubelet
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Cilium health
  inbound_rule {
    protocol    = "tcp"
    port_range  = "4240"
    source_tags = [digitalocean_tag.controllers.name, digitalocean_tag.workers.name]
  }

  # IANA vxlan (flannel, calico)
  inbound_rule {
    protocol    = "udp"
    port_range  = "4789"
    source_tags = [digitalocean_tag.controllers.name, digitalocean_tag.workers.name]
  }

  # Linux vxlan (Cilium)
  inbound_rule {
    protocol    = "udp"
    port_range  = "8472"
    source_tags = [digitalocean_tag.controllers.name, digitalocean_tag.workers.name]
  }

  # Allow Prometheus to scrape node-exporter
  inbound_rule {
    protocol    = "tcp"
    port_range  = "9100"
    source_tags = [digitalocean_tag.workers.name]
  }

  # Allow Prometheus to scrape kube-proxy
  inbound_rule {
    protocol    = "tcp"
    port_range  = "10249"
    source_tags = [digitalocean_tag.workers.name]
  }

  # Kubelet
  inbound_rule {
    protocol    = "tcp"
    port_range  = "10250"
    source_tags = [digitalocean_tag.controllers.name, digitalocean_tag.workers.name]
  }

  # allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "controllers" {
  name = "${var.cluster_name}-controllers"

  tags = [digitalocean_tag.controllers.name]

  # etcd
  inbound_rule {
    protocol    = "tcp"
    port_range  = "2379-2380"
    source_tags = [digitalocean_tag.controllers.name]
  }

  # etcd metrics
  inbound_rule {
    protocol    = "tcp"
    port_range  = "2381"
    source_tags = [digitalocean_tag.workers.name]
  }

  # kube-apiserver
  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # kube-scheduler metrics, kube-controller-manager metrics
  inbound_rule {
    protocol    = "tcp"
    port_range  = "10257-10259"
    source_tags = [digitalocean_tag.workers.name]
  }
}

resource "digitalocean_firewall" "workers" {
  name = "${var.cluster_name}-workers"

  tags = [digitalocean_tag.workers.name]

  # allow HTTP/HTTPS ingress
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "10254"
    source_addresses = ["0.0.0.0/0"]
  }
}

