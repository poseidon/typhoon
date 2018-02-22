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

# Controller Network Load Balancer
resource "aws_lb" "apiserver" {
  name               = "${var.cluster_name}-apiserver"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.public.*.id}"]
}

resource "aws_lb_target_group" "apiserver" {
  name     = "${var.cluster_name}-apiserver"
  port     = 443
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

resource "aws_lb_listener" "apiserver-https" {
  load_balancer_arn = "${aws_lb.apiserver.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.apiserver.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "controllers" {
  count = "${var.controller_count}"

  target_group_arn = "${aws_lb_target_group.apiserver.arn}"
  target_id        = "${element(aws_instance.controllers.*.id, count.index)}"
  port             = 443
}