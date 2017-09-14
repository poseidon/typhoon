# Managed Instance Group
resource "google_compute_instance_group_manager" "controllers" {
  name        = "${var.cluster_name}-controller-group"
  description = "Compute instance group of ${var.cluster_name} controllers"

  # Instance name prefix for instances in the group
  base_instance_name = "${var.cluster_name}-controller"
  instance_template  = "${google_compute_instance_template.controller.self_link}"
  update_strategy    = "RESTART"
  zone               = "${var.zone}"
  target_size        = "${var.count}"

  # Target pool instances in the group should be added into
  target_pools = [
    "${google_compute_target_pool.controllers.self_link}",
  ]
}

# Controller Container Linux Config
data "template_file" "controller_config" {
  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    k8s_dns_service_ip      = "${cidrhost(var.service_cidr, 10)}"
    k8s_etcd_service_ip     = "${cidrhost(var.service_cidr, 15)}"
    ssh_authorized_keys     = "${var.ssh_authorized_key}"
    kubeconfig_ca_cert      = "${var.kubeconfig_ca_cert}"
    kubeconfig_kubelet_cert = "${var.kubeconfig_kubelet_cert}"
    kubeconfig_kubelet_key  = "${var.kubeconfig_kubelet_key}"
    kubeconfig_server       = "${var.kubeconfig_server}"
  }
}

data "ct_config" "controller_ign" {
  content      = "${data.template_file.controller_config.rendered}"
  pretty_print = false
}

resource "google_compute_instance_template" "controller" {
  name_prefix  = "${var.cluster_name}-controller-"
  description  = "Controller Instance template"
  machine_type = "${var.machine_type}"

  metadata {
    user-data = "${data.ct_config.controller_ign.rendered}"
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

  lifecycle {
    # To update an Instance Template, Terraform should replace the existing resource
    create_before_destroy = true
  }
}
