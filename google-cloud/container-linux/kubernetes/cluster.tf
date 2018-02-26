module "controllers" {
  source       = "controllers"
  cluster_name = "${var.cluster_name}"

  # GCE
  network       = "${google_compute_network.network.name}"
  count         = "${var.controller_count}"
  region        = "${var.region}"
  dns_zone      = "${var.dns_zone}"
  dns_zone_name = "${var.dns_zone_name}"
  machine_type  = "${var.machine_type}"
  os_image      = "${var.os_image}"

  # configuration
  networking            = "${var.networking}"
  kubeconfig            = "${module.bootkube.kubeconfig}"
  ssh_authorized_key    = "${var.ssh_authorized_key}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
}

module "workers" {
  source       = "workers"
  cluster_name = "${var.cluster_name}"

  # GCE
  network      = "${google_compute_network.network.name}"
  region       = "${var.region}"
  count        = "${var.worker_count}"
  machine_type = "${var.machine_type}"
  os_image     = "${var.os_image}"
  preemptible  = "${var.worker_preemptible}"

  # configuration
  kubeconfig            = "${module.bootkube.kubeconfig}"
  ssh_authorized_key    = "${var.ssh_authorized_key}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
}
