# kube-apiserver Network Load Balancer DNS Record
resource "aws_route53_record" "apiserver" {
  zone_id = "${var.dns_zone_id}"

  name = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"

  # AWS recommends their special "alias" records for ELBs
  alias {
    name                   = "${aws_lb.apiserver.dns_name}"
    zone_id                = "${aws_lb.apiserver.zone_id}"
    evaluate_target_health = true
  }
}

# Network Load Balancer for apiservers
resource "aws_lb" "apiserver" {
  name               = "${var.cluster_name}-apiserver"
  load_balancer_type = "network"
  internal           = false

  subnets = ["${aws_subnet.public.*.id}"]

  enable_cross_zone_load_balancing = true
}

# Forward HTTP traffic to controllers
resource "aws_lb_listener" "apiserver-https" {
  load_balancer_arn = "${aws_lb.apiserver.arn}"
  protocol          = "TCP"
  port              = "443"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.controllers.arn}"
  }
}

# Target group of controllers
resource "aws_lb_target_group" "controllers" {
  name        = "${var.cluster_name}-controllers"
  vpc_id      = "${aws_vpc.network.id}"
  target_type = "instance"

  protocol = "TCP"
  port     = 443

  # Kubelet HTTP health check
  health_check {
    protocol = "TCP"
    port     = 443

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Interval between health checks required to be 10 or 30
    interval = 10
  }
}

# Attach controller instances to apiserver NLB
resource "aws_lb_target_group_attachment" "controllers" {
  count = "${var.controller_count}"

  target_group_arn = "${aws_lb_target_group.controllers.arn}"
  target_id        = "${element(aws_instance.controllers.*.id, count.index)}"
  port             = 443
}
