# Controllers AutoScaling Group
resource "aws_autoscaling_group" "controllers" {
  name           = "${var.cluster_name}-controller"
  load_balancers = ["${aws_elb.controllers.id}"]

  # count
  desired_capacity = "${var.controller_count}"
  min_size         = "${var.controller_count}"
  max_size         = "${var.controller_count}"

  # network
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  # template
  launch_configuration = "${aws_launch_configuration.controller.name}"

  lifecycle {
    # override the default destroy and replace update behavior
    create_before_destroy = true
    ignore_changes        = ["image_id"]
  }

  tags = [{
    key                 = "Name"
    value               = "${var.cluster_name}-controller"
    propagate_at_launch = true
  }]
}

# Controller template
resource "aws_launch_configuration" "controller" {
  name_prefix   = "${var.cluster_name}-controller-template-"
  image_id      = "${data.aws_ami.coreos.image_id}"
  instance_type = "${var.controller_type}"

  user_data = "${data.ct_config.controller_ign.rendered}"

  # storage
  root_block_device {
    volume_type = "standard"
    volume_size = "${var.disk_size}"
  }

  # network
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.controller.id}"]

  lifecycle {
    // Override the default destroy and replace update behavior
    create_before_destroy = true
  }
}

# Controller Container Linux Config
data "template_file" "controller_config" {
  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    k8s_dns_service_ip      = "${cidrhost(var.service_cidr, 10)}"
    k8s_etcd_service_ip     = "${cidrhost(var.service_cidr, 15)}"
    ssh_authorized_key      = "${var.ssh_authorized_key}"
    kubeconfig_ca_cert      = "${module.bootkube.ca_cert}"
    kubeconfig_kubelet_cert = "${module.bootkube.kubelet_cert}"
    kubeconfig_kubelet_key  = "${module.bootkube.kubelet_key}"
    kubeconfig_server       = "${module.bootkube.server}"
  }
}

data "ct_config" "controller_ign" {
  content      = "${data.template_file.controller_config.rendered}"
  pretty_print = false
}

# Security Group (instance firewall)

resource "aws_security_group" "controller" {
  name        = "${var.cluster_name}-controller"
  description = "${var.cluster_name} controller security group"

  vpc_id = "${aws_vpc.network.id}"

  tags = "${map("Name", "${var.cluster_name}-controller")}"
}

resource "aws_security_group_rule" "controller-icmp" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "icmp"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controller-ssh" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controller-apiserver" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controller-etcd" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "controller-bootstrap-etcd" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 12379
  to_port   = 12380
  self      = true
}

resource "aws_security_group_rule" "controller-flannel" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8472
  to_port                  = 8472
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-flannel-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "udp"
  from_port = 8472
  to_port   = 8472
  self      = true
}

resource "aws_security_group_rule" "controller-kubelet-read" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10255
  to_port                  = 10255
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-kubelet-read-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255
  self      = true
}

resource "aws_security_group_rule" "controller-bgp" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 179
  to_port                  = 179
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-bgp-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 179
  to_port   = 179
  self      = true
}

resource "aws_security_group_rule" "controller-ipip" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = 4
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-ipip-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = 4
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "controller-ipip-legacy" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = 94
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-ipip-legacy-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = 94
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "controller-egress" {
  security_group_id = "${aws_security_group.controller.id}"

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
