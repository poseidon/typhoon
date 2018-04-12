# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/roytharpe/terraform-render-bootkube.git?ref=a4ff9189fcfb0a0ec42870244a79f6dc27075097"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${var.k8s_domain_name}"]
  etcd_servers          = ["${var.controller_domains}"]
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
}
