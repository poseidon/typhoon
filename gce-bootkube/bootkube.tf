# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/dghubble/bootkube-terraform.git?ref=3720aff28a465987e079dcd74fe3b6d5046d7010"

  cluster_name                  = "${var.cluster_name}"
  api_servers                   = ["${var.k8s_domain_name}"]
  etcd_servers                  = ["http://127.0.0.1:2379"]
  asset_dir                     = "${var.asset_dir}"
  pod_cidr                      = "${var.pod_cidr}"
  service_cidr                  = "${var.service_cidr}"
  experimental_self_hosted_etcd = "true"
}
