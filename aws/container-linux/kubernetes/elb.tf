# Controller Network Load Balancer DNS Record
resource "aws_route53_record" "controllers" {
  zone_id = "${var.dns_zone_id}"

  name = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"

  # AWS recommends their special "alias" records for ELBs
  alias {
    name                   = "${aws_elb.controllers.dns_name}"
    zone_id                = "${aws_elb.controllers.zone_id}"
    evaluate_target_health = true
  }
}

# Controller Network Load Balancer
resource "aws_elb" "controllers" {
  name            = "${var.cluster_name}-controllers"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.controller.id}"]

  listener {
    lb_port           = 443
    lb_protocol       = "tcp"
    instance_port     = 443
    instance_protocol = "tcp"
  }

  instances = ["${aws_instance.controllers.*.id}"]

  # Kubelet HTTP health check
  health_check {
    target              = "HTTP:10255/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = 5
    interval            = 6
  }

  idle_timeout                = 3600
  connection_draining         = true
  connection_draining_timeout = 300
}
