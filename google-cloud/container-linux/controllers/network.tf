# DNS record set to the network load balancer over controllers
resource "google_dns_record_set" "k8s_dns" {
  # Managed DNS Zone name
  managed_zone = "${var.dns_base_zone_name}"

  # Name of the DNS record
  #name = "${format("%s.%s.", var.cluster_name, var.dns_base_zone)}"
  name = "${var.k8s_domain_name}."

  type = "A"
  ttl  = 300

  # compute instance public IP
  rrdatas = ["${google_compute_address.controllers-ip.address}"]
}

# Static IP for the Network Load Balancer
resource "google_compute_address" "controllers-ip" {
  name = "${var.cluster_name}-controllers-ip"
}

# Network Load Balancer (i.e. forwarding rules)
resource "google_compute_forwarding_rule" "controller-https-rule" {
  name       = "${var.cluster_name}-controller-https-rule"
  ip_address = "${google_compute_address.controllers-ip.address}"
  port_range = "443"
  target     = "${google_compute_target_pool.controllers.self_link}"
}

resource "google_compute_forwarding_rule" "controller-ssh-rule" {
  name       = "${var.cluster_name}-controller-ssh-rule"
  ip_address = "${google_compute_address.controllers-ip.address}"
  port_range = "22"
  target     = "${google_compute_target_pool.controllers.self_link}"
}

# Network Load Balancer target pool of instances.
resource "google_compute_target_pool" "controllers" {
  name = "${var.cluster_name}-controller-pool"

  health_checks = [
    "${google_compute_http_health_check.ingress.name}",
  ]

  session_affinity = "NONE"
}

# Kubelet HTTP Health Check
resource "google_compute_http_health_check" "ingress" {
  name        = "${var.cluster_name}-kubelet-health"
  description = "Health check Kubelet health host port"

  timeout_sec        = 5
  check_interval_sec = 5

  healthy_threshold   = 2
  unhealthy_threshold = 4

  port         = 10255
  request_path = "/healthz"
}
