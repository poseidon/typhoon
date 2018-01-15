# Controller instances

# server groups can handle a maximum of 5 nodes
resource "openstack_compute_servergroup_v2" "controllers" {
  count    = "${var.controller_count > 0 ? 1 + var.controller_count / 5 : 0}"
  name     = "${var.cluster_name}-controllers"
  policies = ["anti-affinity"]
}

resource "openstack_networking_port_v2" "port_controllers" {
  count = "${var.controller_count}"

  name           = "${var.cluster_name}_port_${count.index}"
  network_id     = "${module.network.network_id}"
  admin_state_up = "true"

  security_group_ids = [
    "${openstack_networking_secgroup_v2.controller_pub.id}",
    "${openstack_networking_secgroup_v2.controller_priv.id}",
  ]

  fixed_ip {
    subnet_id = "${element(module.network.private_subnets, count.index)}"
  }
}

resource "openstack_compute_instance_v2" "controllers" {
  count    = "${var.controller_count}"
  name     = "${var.cluster_name}_${count.index}"
  image_id = "${element(coalescelist(data.openstack_images_image_v2.coreos.*.id, list(var.image_id)), 0)}"

  flavor_name = "${var.controller_flavor_name}"

  user_data = "${element(data.ignition_config.controller.*.rendered, count.index)}"

  network {
    port = "${element(openstack_networking_port_v2.port_controllers.*.id, count.index)}"
  }

  scheduler_hints {
    # dividing by 5 allows to fill the groups one by one, instead of round robin them
    group = "${element(openstack_compute_servergroup_v2.controllers.*.id, count.index / 5 )}"
  }

  metadata = {
    Name = "${var.cluster_name}-controller-${count.index}"
  }
}

# Security Group (instance firewall)
resource "openstack_networking_secgroup_v2" "controller_pub" {
  name        = "${var.cluster_name}-controller-pub"
  description = "${var.cluster_name} controller security group for public access"
}

resource "openstack_networking_secgroup_v2" "controller_priv" {
  name        = "${var.cluster_name}-controller-privif"
  description = "${var.cluster_name} controller security group for private access"
}

resource "openstack_networking_secgroup_rule_v2" "controller-icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "${var.host_cidr}"
  protocol          = "icmp"
  security_group_id = "${openstack_networking_secgroup_v2.controller_pub.id}"
}

# resource "openstack_networking_secgroup_rule_v2" "controller-ssh" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   remote_ip_prefix  = "${var.host_cidr}"
#   port_range_min    = 22
#   port_range_max    = 22
#   security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
# }

resource "openstack_networking_secgroup_rule_v2" "controller-apiserver" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = "${openstack_networking_secgroup_v2.controller_pub.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-flannel" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-flannel-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-node-exporter" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-kubelet-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-kubelet-read" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10255
  port_range_max    = 10255
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-kubelet-read-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10255
  port_range_max    = 10255
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-bgp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 179
  port_range_max    = 179
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-bgp-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 179
  port_range_max    = 179
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-ipip" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "4"
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-ipip-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "4"
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-ipip-legacy" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "94"
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-ipip-legacy-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "94"
  security_group_id = "${openstack_networking_secgroup_v2.controller_priv.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "controller-egress-ipv4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.controller_pub.id}"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "controller-egress-ipv6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.controller_pub.id}"
  remote_ip_prefix  = "::0"
}
