# kube-apiserver Network Load Balancer DNS Record
resource "aws_route53_record" "bastion" {
  zone_id    = "${var.dns_zone_id}"

  name = "${format("bastion.%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"

  # AWS recommends their special "alias" records for ELBs
  alias {
    name                   = "${aws_lb.bastion.dns_name}"
    zone_id                = "${aws_lb.bastion.zone_id}"
    evaluate_target_health = true
  }
}

# Controller Network Load Balancer
resource "aws_lb" "bastion" {
  name               = "${var.cluster_name}-bastion"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.public.*.id}"]
}

resource "aws_lb_target_group" "bastion" {
  name     = "${var.cluster_name}-bastion"
  port     = 22
  protocol = "TCP"
  vpc_id   = "${aws_vpc.network.id}"

  # Kubelet HTTP health check
  health_check {
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_listener" "bastion-22" {
  load_balancer_arn = "${aws_lb.bastion.arn}"
  port              = "22"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.bastion.arn}"
    type             = "forward"
  }
}

# Private network needs a bastion to be able to connect to Instances in the private network.
resource "aws_security_group" "bastion" {
  name        = "${var.cluster_name}-bastion"
  vpc_id      = "${aws_vpc.network.id}"
  description = "Security group for bastion"

  tags = {
    KubernetesCluster = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "bastion-ssh" {
  security_group_id = "${aws_security_group.bastion.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-egress" {
  security_group_id = "${aws_security_group.bastion.id}"

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_launch_configuration" "bastion" {
  image_id                    = "${data.aws_ami.coreos.image_id}"
  instance_type               = "t2.micro"
  key_name                    = "${var.keypair_name}"
  security_groups             = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 12
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = false
  }
}

resource "aws_autoscaling_group" "bastion" {
  name                 = "bastion-asg"
  launch_configuration = "${aws_launch_configuration.bastion.name}"
  min_size             = 1
  max_size             = 1

  # network
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  lifecycle {
    create_before_destroy = false
  }

  tags = [{
    key                 = "Name"
    value               = "${var.cluster_name}-bastion"
    propagate_at_launch = true
  }]
}

resource "aws_autoscaling_attachment" "bastion_tg_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.bastion.id}"
  alb_target_group_arn   = "${aws_lb_target_group.bastion.arn}"
}
