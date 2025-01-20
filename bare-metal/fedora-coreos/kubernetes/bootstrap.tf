# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=997f6012b540617f7fda1603d169e6ec92be125c"

  cluster_name = var.cluster_name
  api_servers  = [var.k8s_domain_name]
  etcd_servers = var.controllers.*.domain
  networking   = var.networking
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
  components   = var.components
}


