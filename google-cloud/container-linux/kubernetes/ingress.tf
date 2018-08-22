# Static IPv4 address for the TCP Proxy Load Balancer
resource "google_compute_global_address" "ingress-ipv4" {
  name       = "${var.cluster_name}-ingress-ip"
  ip_version = "IPV4"
}

# Forward IPv4 TCP traffic to the HTTP proxy load balancer
# Google Cloud does not allow TCP proxies for port 80. Must use HTTP proxy.
resource "google_compute_global_forwarding_rule" "ingress-http" {
  name        = "${var.cluster_name}-ingress-http"
  ip_address  = "${google_compute_global_address.ingress-ipv4.address}"
  ip_protocol = "TCP"
  port_range  = "80"
  target      = "${google_compute_target_http_proxy.ingress-http.self_link}"
}

# Forward IPv4 TCP traffic to the TCP proxy load balancer
resource "google_compute_global_forwarding_rule" "ingress-https" {
  name        = "${var.cluster_name}-ingress-https"
  ip_address  = "${google_compute_global_address.ingress-ipv4.address}"
  ip_protocol = "TCP"
  port_range  = "443"
  target      = "${google_compute_target_tcp_proxy.ingress-https.self_link}"
}

# HTTP proxy load balancer for ingress controllers
resource "google_compute_target_http_proxy" "ingress-http" {
  name        = "${var.cluster_name}-ingress-http"
  description = "Distribute HTTP load across ${var.cluster_name} workers"
  url_map     = "${google_compute_url_map.ingress-http.self_link}"
}

# TCP proxy load balancer for ingress controllers
resource "google_compute_target_tcp_proxy" "ingress-https" {
  name            = "${var.cluster_name}-ingress-https"
  description     = "Distribute HTTPS load across ${var.cluster_name} workers"
  backend_service = "${google_compute_backend_service.ingress-https.self_link}"
}

# HTTP URL Map (required)
resource "google_compute_url_map" "ingress-http" {
  name = "${var.cluster_name}-ingress-http"

  # Do not add host/path rules for applications here. Use Ingress resources.
  default_service = "${google_compute_backend_service.ingress-http.self_link}"
}

# Backend service backed by managed instance group of workers
resource "google_compute_backend_service" "ingress-http" {
  name        = "${var.cluster_name}-ingress-http"
  description = "${var.cluster_name} ingress service"

  protocol         = "HTTP"
  port_name        = "http"
  session_affinity = "NONE"
  timeout_sec      = "60"

  backend {
    group = "${module.workers.instance_group}"
  }

  health_checks = ["${google_compute_health_check.ingress.self_link}"]
}

# Backend service backed by managed instance group of workers
resource "google_compute_backend_service" "ingress-https" {
  name        = "${var.cluster_name}-ingress-https"
  description = "${var.cluster_name} ingress service"

  protocol         = "TCP"
  port_name        = "https"
  session_affinity = "NONE"
  timeout_sec      = "60"

  backend {
    group = "${module.workers.instance_group}"
  }

  health_checks = ["${google_compute_health_check.ingress.self_link}"]
}

# Ingress HTTP Health Check
resource "google_compute_health_check" "ingress" {
  name        = "${var.cluster_name}-ingress-health"
  description = "Health check for Ingress controller"

  timeout_sec        = 5
  check_interval_sec = 5

  healthy_threshold   = 2
  unhealthy_threshold = 4

  http_health_check {
    port         = 10254
    request_path = "/healthz"
  }
}
