# Regional managed instance group maintains a homogeneous set of workers that
# span the zones in the region.
resource "google_compute_region_instance_group_manager" "workers" {
  name        = "${var.name}-worker-group"
  description = "Compute instance group of ${var.name} workers"

  # instance name prefix for instances in the group
  base_instance_name = "${var.name}-worker"
  instance_template  = "${google_compute_instance_template.worker.self_link}"
  region             = "${var.region}"

  target_size = "${var.count}"

  # target pool to which instances in the group should be added
  target_pools = [
    "${google_compute_target_pool.workers.self_link}",
  ]
}

# Worker Container Linux Config
data "template_file" "worker_config" {
  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars = {
    kubeconfig            = "${indent(10, var.kubeconfig)}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "ct_config" "worker_ign" {
  content      = "${data.template_file.worker_config.rendered}"
  pretty_print = false
  snippets     = ["${var.clc_snippets}"]
}

resource "google_compute_instance_template" "worker" {
  name_prefix  = "${var.name}-worker-"
  description  = "Worker Instance template"
  machine_type = "${var.machine_type}"

  metadata {
    user-data = "${data.ct_config.worker_ign.rendered}"
  }

  scheduling {
    automatic_restart = "${var.preemptible ? false : true}"
    preemptible       = "${var.preemptible}"
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = "${var.os_image}"
    disk_size_gb = "${var.disk_size}"
  }

  network_interface {
    network = "${var.network}"

    # Ephemeral external IP
    access_config = {}
  }

  can_ip_forward = true
  tags           = ["worker", "${var.cluster_name}-worker", "${var.name}-worker"]

  guest_accelerator {
    count = "${var.accelerator_count}"
    type  = "${var.accelerator_type}"
  }

  lifecycle {
    # To update an Instance Template, Terraform should replace the existing resource
    create_before_destroy = true
  }
}
