resource "digitalocean_firewall" "rules" {
  name = var.cluster_name

  tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]

  # allow ssh, internal flannel, internal node-exporter, internal kubelet
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol    = "udp"
    port_range  = "4789"
    source_tags = [digitalocean_tag.controllers.name, digitalocean_tag.workers.name]
  }

  inbound_rule {
    protocol    = "tcp"
    port_range  = "9100"
    source_tags = [digitalocean_tag.workers.name]
  }

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

  tags = ["${var.cluster_name}-controller"]

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
    port_range  = "10251-10252"
    source_tags = [digitalocean_tag.workers.name]
  }
}

resource "digitalocean_firewall" "workers" {
  name = "${var.cluster_name}-workers"

  tags = ["${var.cluster_name}-worker"]

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

