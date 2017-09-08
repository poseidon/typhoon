# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/poseidon/bootkube-terraform.git?ref=dbfb11c6eafa08f839eac2834ca1aca35dafe965"

  cluster_name                  = "${var.cluster_name}"
  api_servers                   = ["${format("%s.%s", var.cluster_name, var.dns_zone)}"]
  etcd_servers                  = ["http://127.0.0.1:2379"]
  asset_dir                     = "${var.asset_dir}"
  networking                    = "${var.networking}"
  network_mtu                   = 1440
  pod_cidr                      = "${var.pod_cidr}"
  service_cidr                  = "${var.service_cidr}"
  experimental_self_hosted_etcd = "true"
}
