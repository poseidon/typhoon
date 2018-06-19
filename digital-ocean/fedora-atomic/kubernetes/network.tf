resource "digitalocean_firewall" "rules" {
  name = "${var.cluster_name}"

  tags = ["${var.cluster_name}-controller", "${var.cluster_name}-worker"]

  # allow ssh, apiserver, http/https ingress, and peer-to-peer traffic
  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
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
      port_range       = "6443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol    = "udp"
      port_range  = "1-65535"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "1-65535"
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
