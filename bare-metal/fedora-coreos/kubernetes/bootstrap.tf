# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=3edb0ae646faaf79406e1bb5cc94038edab32f21"

  cluster_name = var.cluster_name
  api_servers  = [var.k8s_domain_name]
  etcd_servers = var.controllers.*.domain
  networking   = var.networking
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
  components   = var.components
}


