# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/poseidon/terraform-render-bootkube.git?ref=1d4db824f09246266a6b9e54df5d4df5dcd4477a"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${var.k8s_domain_name}"]
  etcd_servers          = ["${var.controller_domains}"]
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"

  # Fedora
  trusted_certs_dir = "/etc/pki/tls/certs"
}
