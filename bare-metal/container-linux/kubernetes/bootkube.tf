# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/poseidon/bootkube-terraform.git?ref=48b33db1f1ecd7e34871cbbcab25186dfd343074"

  cluster_name                  = "${var.cluster_name}"
  api_servers                   = ["${var.k8s_domain_name}"]
  etcd_servers                  = ["${var.controller_domains}"]
  asset_dir                     = "${var.asset_dir}"
  networking                    = "${var.networking}"
  network_mtu                   = "${var.network_mtu}"
  pod_cidr                      = "${var.pod_cidr}"
  service_cidr                  = "${var.service_cidr}"
}
