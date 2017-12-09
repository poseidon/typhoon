module "controllers" {
  source             = "controllers"
  cluster_name       = "${var.cluster_name}"
  ssh_authorized_key = "${var.ssh_authorized_key}"

  # GCE
  network       = "${google_compute_network.network.name}"
  count         = "${var.controller_count}"
  region        = "${var.region}"
  dns_zone      = "${var.dns_zone}"
  dns_zone_name = "${var.dns_zone_name}"
  machine_type  = "${var.machine_type}"
  os_image      = "${var.os_image}"

  # configuration
  networking              = "${var.networking}"
  service_cidr            = "${var.service_cidr}"
  cluster_domain_suffix   = "${var.cluster_domain_suffix}"
  kubeconfig_ca_cert      = "${module.bootkube.ca_cert}"
  kubeconfig_kubelet_cert = "${module.bootkube.kubelet_cert}"
  kubeconfig_kubelet_key  = "${module.bootkube.kubelet_key}"
  kubeconfig_server       = "${module.bootkube.server}"
}

module "workers" {
  source             = "workers"
  cluster_name       = "${var.cluster_name}"
  ssh_authorized_key = "${var.ssh_authorized_key}"

  # GCE
  network      = "${google_compute_network.network.name}"
  region       = "${var.region}"
  count        = "${var.worker_count}"
  machine_type = "${var.machine_type}"
  os_image     = "${var.os_image}"
  preemptible  = "${var.worker_preemptible}"

  # configuration
  service_cidr            = "${var.service_cidr}"
  cluster_domain_suffix   = "${var.cluster_domain_suffix}"
  kubeconfig_ca_cert      = "${module.bootkube.ca_cert}"
  kubeconfig_kubelet_cert = "${module.bootkube.kubelet_cert}"
  kubeconfig_kubelet_key  = "${module.bootkube.kubelet_key}"
  kubeconfig_server       = "${module.bootkube.server}"
}
