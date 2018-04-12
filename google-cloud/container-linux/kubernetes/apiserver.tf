# Static IPv4 address for the Network Load Balancer
resource "google_compute_address" "controllers-ip" {
  name = "${var.cluster_name}-controllers-ip"
}

# DNS record for the Network Load Balancer
resource "google_dns_record_set" "controllers" {
  # DNS Zone name where record should be created
  managed_zone = "${var.dns_zone_name}"

  # DNS record
  name = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"
  ttl  = 300

  # IPv4 address of controllers' network load balancer
  rrdatas = ["${google_compute_address.controllers-ip.address}"]
}

# Network Load Balancer for controllers
resource "google_compute_forwarding_rule" "controller-https-rule" {
  name       = "${var.cluster_name}-controller-https-rule"
  ip_address = "${google_compute_address.controllers-ip.address}"
  port_range = "443"
  target     = "${google_compute_target_pool.controllers.self_link}"
}

# Target pool of instances for the controller(s) Network Load Balancer
resource "google_compute_target_pool" "controllers" {
  name = "${var.cluster_name}-controller-pool"

  instances = [
    "${google_compute_instance.controllers.*.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.kubelet.name}",
  ]

  session_affinity = "NONE"
}

# Kubelet HTTP Health Check
resource "google_compute_http_health_check" "kubelet" {
  name        = "${var.cluster_name}-kubelet-health"
  description = "Health check Kubelet health host port"

  timeout_sec        = 5
  check_interval_sec = 5

  healthy_threshold   = 2
  unhealthy_threshold = 4

  port         = 10255
  request_path = "/healthz"
}
