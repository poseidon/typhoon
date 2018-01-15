# Workers anti affinity Group
# server groups can handle a maximum of 5 nodes
resource "openstack_compute_servergroup_v2" "workers" {
  count    = "${var.worker_count > 0 ? 1 + var.worker_count / 5 : 0}"
  name     = "${var.cluster_name}-workers"
  policies = ["anti-affinity"]
}

resource "openstack_networking_port_v2" "port_workers" {
  count = "${var.worker_count}"

  name           = "${var.cluster_name}_port_${count.index}"
  network_id     = "${module.network.network_id}"
  admin_state_up = "true"

  security_group_ids = [
    "${openstack_networking_secgroup_v2.worker.id}"
  ]

  fixed_ip {
    subnet_id = "${element(module.network.private_subnets, count.index)}"
  }
}

resource "openstack_compute_instance_v2" "workers" {
  count    = "${var.worker_count}"
  name     = "${var.cluster_name}_${count.index}_wrk"
  image_id = "${element(coalescelist(data.openstack_images_image_v2.coreos.*.id, list(var.image_id)), 0)}"

  flavor_name = "${var.worker_flavor_name}"

  user_data = "${element(data.ignition_config.worker.*.rendered, count.index)}"

  network {
    access_network = true
    port = "${element(openstack_networking_port_v2.port_workers.*.id, count.index)}"
  }

  scheduler_hints {
    # server groups can handle a maximum of 5 nodes
    # dividing by 5 allows to fill the groups one by one, instead of round robin them
    group = "${element(openstack_compute_servergroup_v2.workers.*.id, count.index / 5)}"
  }

  metadata = {
    Name = "${var.cluster_name}-worker-${count.index}"
  }
}

# Security Group (instance firewall)
resource "openstack_networking_secgroup_v2" "worker" {
  name        = "${var.cluster_name}-worker-pub"
  description = "${var.cluster_name} worker security group"
}

resource "openstack_networking_secgroup_rule_v2" "worker-icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "icmp"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-flannel" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-flannel-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-node-exporter" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-kubelet-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-kubelet-read" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10255
  port_range_max    = 10255
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-kubelet-read-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10255
  port_range_max    = 10255
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-health-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10254
  port_range_max    = 10254
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-bgp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 179
  port_range_max    = 179
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-bgp-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 179
  port_range_max    = 179
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-ipip" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "4"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-ipip-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "4"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-ipip-legacy" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "94"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller_priv.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-ipip-legacy-self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "94"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-egress-ipv4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "worker-egress-ipv6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
  remote_ip_prefix  = "::0"
}
