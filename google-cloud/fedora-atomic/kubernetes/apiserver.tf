# TCP Proxy load balancer DNS record
resource "google_dns_record_set" "apiserver" {
  # DNS Zone name where record should be created
  managed_zone = "${var.dns_zone_name}"

  # DNS record
  name = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"
  ttl  = 300

  # IPv4 address of apiserver TCP Proxy load balancer
  rrdatas = ["${google_compute_global_address.apiserver-ipv4.address}"]
}

# Static IPv4 address for the TCP Proxy Load Balancer
resource "google_compute_global_address" "apiserver-ipv4" {
  name       = "${var.cluster_name}-apiserver-ip"
  ip_version = "IPV4"
}

# Forward IPv4 TCP traffic to the TCP proxy load balancer
resource "google_compute_global_forwarding_rule" "apiserver" {
  name        = "${var.cluster_name}-apiserver"
  ip_address  = "${google_compute_global_address.apiserver-ipv4.address}"
  ip_protocol = "TCP"
  port_range  = "443"
  target      = "${google_compute_target_tcp_proxy.apiserver.self_link}"
}

# TCP Proxy Load Balancer for apiservers
resource "google_compute_target_tcp_proxy" "apiserver" {
  name            = "${var.cluster_name}-apiserver"
  description     = "Distribute TCP load across ${var.cluster_name} controllers"
  backend_service = "${google_compute_backend_service.apiserver.self_link}"
}

# Backend service backed by unmanaged instance groups
resource "google_compute_backend_service" "apiserver" {
  name        = "${var.cluster_name}-apiserver"
  description = "${var.cluster_name} apiserver service"

  protocol         = "TCP"
  port_name        = "apiserver"
  session_affinity = "NONE"
  timeout_sec      = "60"

  # controller(s) spread across zonal instance groups
  backend {
    group = "${google_compute_instance_group.controllers.0.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.controllers.1.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.controllers.2.self_link}"
  }

  health_checks = ["${google_compute_health_check.apiserver.self_link}"]
}

# Instance group of heterogeneous (unmanged) controller instances
resource "google_compute_instance_group" "controllers" {
  count = "${length(local.zones)}"

  name = "${format("%s-controllers-%s", var.cluster_name, element(local.zones, count.index))}"
  zone = "${element(local.zones, count.index)}"

  named_port {
    name = "apiserver"
    port = "443"
  }

  # add instances in the zone into the instance group
  instances = [
    "${matchkeys(google_compute_instance.controllers.*.self_link,
      google_compute_instance.controllers.*.zone,
      list(element(local.zones, count.index)))}",
  ]
}

# TCP health check for apiserver
resource "google_compute_health_check" "apiserver" {
  name        = "${var.cluster_name}-apiserver-tcp-health"
  description = "TCP health check for kube-apiserver"

  timeout_sec        = 5
  check_interval_sec = 5

  healthy_threshold   = 1
  unhealthy_threshold = 3

  tcp_health_check {
    port = "443"
  }
}
