# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=c7e2a637d7090d9e8f98a146a39872cfc546997c"

  cluster_name           = var.cluster_name
  api_servers            = [var.k8s_domain_name]
  service_account_issuer = var.service_account_issuer
  etcd_servers           = var.controllers.*.domain
  networking             = var.networking
  pod_cidr               = var.pod_cidr
  service_cidr           = var.service_cidr
  components             = var.components
}


