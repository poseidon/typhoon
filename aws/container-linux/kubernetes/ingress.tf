# Ingress Network Load Balancer
resource "aws_elb" "ingress" {
  name            = "${var.cluster_name}-ingress"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.worker.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "tcp"
    instance_port     = 80
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 443
    lb_protocol       = "tcp"
    instance_port     = 443
    instance_protocol = "tcp"
  }

  # Kubelet HTTP health check
  health_check {
    target              = "HTTP:10254/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = 5
    interval            = 6
  }

  connection_draining         = true
  connection_draining_timeout = 300
}
