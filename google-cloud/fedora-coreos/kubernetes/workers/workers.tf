# Managed instance group of workers
resource "google_compute_region_instance_group_manager" "workers" {
  name        = "${var.name}-worker-group"
  description = "Compute instance group of ${var.name} workers"

  # instance name prefix for instances in the group
  base_instance_name = "${var.name}-worker"
  region             = var.region
  version {
    name              = "default"
    instance_template = google_compute_instance_template.worker.self_link
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
}

# Worker instance template
resource "google_compute_instance_template" "worker" {
  name_prefix  = "${var.name}-worker-"
  description  = "Worker Instance template"
  machine_type = var.machine_type

  metadata = {
    user-data = data.ct_config.worker-ignition.rendered
  }

  scheduling {
    automatic_restart = var.preemptible ? false : true
    preemptible       = var.preemptible
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = data.google_compute_image.fedora-coreos.self_link
    disk_size_gb = var.disk_size
  }

  network_interface {
    network = var.network

    # Ephemeral external IP
    access_config {
    }
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

# Worker Ignition config
data "ct_config" "worker-ignition" {
  content  = data.template_file.worker-config.rendered
  strict   = true
  snippets = var.snippets
}

# Worker Fedora CoreOS config
data "template_file" "worker-config" {
  template = file("${path.module}/fcc/worker.yaml")

  vars = {
    kubeconfig             = indent(10, var.kubeconfig)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
    node_labels            = join(",", var.node_labels)
    node_taints            = join(",", var.node_taints)
  }
}

