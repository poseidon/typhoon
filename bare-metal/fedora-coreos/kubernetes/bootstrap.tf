# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=ff7ec52d0a5e97b8ca6b86a80a7e5e1ea8570487"

  cluster_name                    = var.cluster_name
  api_servers                     = [var.k8s_domain_name]
  etcd_servers                    = var.controllers.*.domain
  asset_dir                       = var.asset_dir
  networking                      = var.networking
  network_mtu                     = var.network_mtu
  network_ip_autodetection_method = var.network_ip_autodetection_method
  pod_cidr                        = var.pod_cidr
  service_cidr                    = var.service_cidr
  cluster_domain_suffix           = var.cluster_domain_suffix
  enable_reporting                = var.enable_reporting
  enable_aggregation              = var.enable_aggregation

  trusted_certs_dir = "/etc/pki/tls/certs"
}


