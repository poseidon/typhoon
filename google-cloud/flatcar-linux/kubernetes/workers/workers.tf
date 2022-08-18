# Managed instance group of workers
resource "google_compute_region_instance_group_manager" "workers" {
  name        = "${var.name}-worker"
  description = "Compute instance group of ${var.name} workers"

  # instance name prefix for instances in the group
  base_instance_name = "${var.name}-worker"
  region             = var.region
  version {
    name              = "default"
    instance_template = google_compute_instance_template.worker.self_link
  }

  # Roll out MIG instance template changes by replacing instances.
  # - Surge to create new instances, then delete old instances.
  # - Replace ensures new Ignition is picked up
  update_policy {
    type                  = "PROACTIVE"
    max_surge_fixed       = 3
    max_unavailable_fixed = 0
    minimal_action        = "REPLACE"
  }

  target_size  = var.worker_count
  target_pools = [google_compute_target_pool.workers.self_link]

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.worker.id
    initial_delay_sec = 300
  }
}

# Health check for worker Kubelet
resource "google_compute_health_check" "worker" {
  name        = "${var.name}-worker-health"
  description = "Health check for worker node"

  timeout_sec        = 20
  check_interval_sec = 30

  healthy_threshold   = 1
  unhealthy_threshold = 6

  http_health_check {
    port         = "10256"
    request_path = "/healthz"
  }
}

# Worker instance template
resource "google_compute_instance_template" "worker" {
  name_prefix  = "${var.name}-worker-"
  description  = "Worker Instance template"
  machine_type = var.machine_type

  metadata = {
    user-data = data.ct_config.worker.rendered
  }

  scheduling {
    provisioning_model = var.preemptible ? "SPOT" : "STANDARD"
    preemptible        = var.preemptible
    automatic_restart  = var.preemptible ? false : true
    # Spot instances with termination action DELETE cannot be used with MIGs
    instance_termination_action = var.preemptible ? "STOP" : null
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = data.google_compute_image.flatcar-linux.self_link
    disk_size_gb = var.disk_size
  }

  network_interface {
    network = var.network
    # Ephemeral external IP
    access_config {}
  }

  can_ip_forward = true
  tags           = ["worker", "${var.cluster_name}-worker", "${var.name}-worker"]

  guest_accelerator {
    count = var.accelerator_count
    type  = var.accelerator_type
  }

  lifecycle {
    ignore_changes = [
      disk[0].source_image
    ]
    # To update an Instance Template, Terraform should replace the existing resource
    create_before_destroy = true
  }
}

# Flatcar Linux worker
data "ct_config" "worker" {
  content = templatefile("${path.module}/butane/worker.yaml", {
    kubeconfig             = indent(10, var.kubeconfig)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
    node_labels            = join(",", var.node_labels)
    node_taints            = join(",", var.node_taints)
  })
  strict   = true
  snippets = var.snippets
}
