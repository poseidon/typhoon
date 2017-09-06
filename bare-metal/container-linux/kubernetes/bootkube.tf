# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/poseidon/bootkube-terraform.git?ref=5ffbfec46dc05721eaf9d15c3c9bbedefaead1bc"

  cluster_name                  = "${var.cluster_name}"
  api_servers                   = ["${var.k8s_domain_name}"]
  etcd_servers                  = ["${var.controller_domains}"]
  asset_dir                     = "${var.asset_dir}"
  networking                    = "${var.networking}"
  network_mtu                   = "${var.network_mtu}"
  pod_cidr                      = "${var.pod_cidr}"
  service_cidr                  = "${var.service_cidr}"
  experimental_self_hosted_etcd = "${var.experimental_self_hosted_etcd}"
}
