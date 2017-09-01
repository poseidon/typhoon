# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/poseidon/bootkube-terraform.git?ref=a52f99e8cc8b395cf2b28f74a9f79c01b63e99ae"

  cluster_name                  = "${var.cluster_name}"
  api_servers                   = ["${var.k8s_domain_name}"]
  etcd_servers                  = ["${var.controller_domains}"]
  asset_dir                     = "${var.asset_dir}"
  networking                    = "${var.networking}"
  pod_cidr                      = "${var.pod_cidr}"
  service_cidr                  = "${var.service_cidr}"
  experimental_self_hosted_etcd = "${var.experimental_self_hosted_etcd}"
}
