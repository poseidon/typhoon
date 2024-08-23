# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=0b78c87997ff96547773e878458ec95485c8b91f"

  cluster_name                    = var.cluster_name
  api_servers                     = [var.k8s_domain_name]
  etcd_servers                    = var.controllers.*.domain
  networking                      = var.networking
  network_mtu                     = var.network_mtu
  network_ip_autodetection_method = var.network_ip_autodetection_method
  pod_cidr                        = var.pod_cidr
  service_cidr                    = var.service_cidr
  components                      = var.components
}

