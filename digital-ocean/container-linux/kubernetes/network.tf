resource "digitalocean_firewall" "rules" {
  name = "${var.cluster_name}"

  tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]

  # allow ssh, http/https ingress, and peer-to-peer traffic
  inbound_rule = [
    {
      protocol = "tcp"
      port_range = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol = "tcp"
      port_range = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol = "tcp"
      port_range = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol = "udp"
      port_range = "all"
      source_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
    },
    {
      protocol = "tcp"
      port_range = "all"
      source_tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]
    },
  ]

  # allow all outbound traffic
  outbound_rule = [
    {
      protocol = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol = "udp"
      port_range = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol = "tcp"
      port_range = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

