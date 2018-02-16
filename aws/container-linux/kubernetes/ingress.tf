# Ingress Network Load Balancer
resource "aws_lb" "ingress" {
  name               = "${var.cluster_name}-ingress"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.public.*.id}"]
}

resource "aws_lb_target_group" "ingress" {
  name     = "${var.cluster_name}-ingress"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.network.id}"

  # Kubelet HTTP health check
  health_check {
    protocol            = "HTTP"
    port                = 10254
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_listener" "ingress-80" {
  load_balancer_arn = "${aws_lb.ingress.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.ingress.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "ingress-443" {
  load_balancer_arn = "${aws_lb.ingress.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.ingress.arn}"
    type             = "forward"
  }
}
