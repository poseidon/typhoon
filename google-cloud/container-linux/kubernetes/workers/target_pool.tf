# Target pool for TCP/UDP load balancing
resource "google_compute_target_pool" "workers" {
  name             = "${var.name}-worker-pool"
  region           = var.region
  session_affinity = "NONE"

  health_checks = [
    google_compute_http_health_check.workers.name,
  ]
}

# HTTP Health Check (for TCP/UDP load balancing)
# Forward rules (regional) to target pools don't support different external
# and internal ports. Health check for nodes with Ingress controllers that
# may support proxying or otherwise satisfy the check.
resource "google_compute_http_health_check" "workers" {
  name        = "${var.name}-target-pool-health"
  description = "Health check for the worker target pool"

  port         = 10254
  request_path = "/healthz"
}

