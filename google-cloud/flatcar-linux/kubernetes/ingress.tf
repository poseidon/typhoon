# Static IPv4 address for Ingress Load Balancing
resource "google_compute_global_address" "ingress-ipv4" {
  name       = "${var.cluster_name}-ingress-ipv4"
  ip_version = "IPV4"
}

# Static IPv6 address for Ingress Load Balancing
resource "google_compute_global_address" "ingress-ipv6" {
  name       = "${var.cluster_name}-ingress-ipv6"
  ip_version = "IPV6"
}

# Forward IPv4 TCP/80 traffic to the TCP proxy load balancer
resource "google_compute_global_forwarding_rule" "ingress-http-ipv4" {
  count = var.enable_http_lb ? 1 : 0

  name                  = "${var.cluster_name}-ingress-http-ipv4"
  ip_address            = google_compute_global_address.ingress-ipv4.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_tcp_proxy.ingress-http[0].self_link
}

# Forward IPv4 TCP/443 traffic to the TCP proxy load balancer
resource "google_compute_global_forwarding_rule" "ingress-https-ipv4" {
  name                  = "${var.cluster_name}-ingress-https-ipv4"
  ip_address            = google_compute_global_address.ingress-ipv4.address
  ip_protocol           = "TCP"
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_tcp_proxy.ingress-https.self_link
}

# Forward IPv6 TCP/80 traffic to the TCP proxy load balancer
resource "google_compute_global_forwarding_rule" "ingress-http-ipv6" {
  count = var.enable_http_lb ? 1 : 0

  name                  = "${var.cluster_name}-ingress-http-ipv6"
  ip_address            = google_compute_global_address.ingress-ipv6.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_tcp_proxy.ingress-http[0].self_link
}

# Forward IPv6 TCP/443 traffic to the TCP proxy load balancer
resource "google_compute_global_forwarding_rule" "ingress-https-ipv6" {
  name                  = "${var.cluster_name}-ingress-https-ipv6"
  ip_address            = google_compute_global_address.ingress-ipv6.address
  ip_protocol           = "TCP"
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_tcp_proxy.ingress-https.self_link
}

# TCP proxy load balancer for ingress traffic
resource "google_compute_target_tcp_proxy" "ingress-http" {
  count = var.enable_http_lb ? 1 : 0

  name            = "${var.cluster_name}-ingress-http"
  description     = "Distribute TCP/80 traffic across ${var.cluster_name} workers"
  backend_service = google_compute_backend_service.ingress-http[0].self_link
}

# TCP proxy load balancer for ingress traffic
resource "google_compute_target_tcp_proxy" "ingress-https" {
  name            = "${var.cluster_name}-ingress-https"
  description     = "Distribute TCP/443 traffic across ${var.cluster_name} workers"
  backend_service = google_compute_backend_service.ingress-https.self_link
}

# Backend service backed by managed instance group of workers
resource "google_compute_backend_service" "ingress-http" {
  count = var.enable_http_lb ? 1 : 0

  name        = "${var.cluster_name}-ingress-http"
  description = "${var.cluster_name} ingress service"

  protocol         = "TCP"
  port_name        = "http"
  session_affinity = "NONE"
  timeout_sec      = "60"

  backend {
    group = module.workers.instance_group
  }

  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.ingress.self_link]
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
    group = module.workers.instance_group
  }

  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.ingress.self_link]
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
