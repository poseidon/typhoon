# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/poseidon/terraform-render-bootkube.git?ref=bcb015e1052192b166b19a1e3b5da0f25051eaf4"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${format("%s.%s", var.cluster_name, var.dns_zone)}"]
  etcd_servers          = ["${formatlist("%s.%s", azurerm_dns_a_record.etcds.*.name, var.dns_zone)}"]
  asset_dir             = "${var.asset_dir}"
  networking            = "flannel"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  enable_reporting      = "${var.enable_reporting}"
}
