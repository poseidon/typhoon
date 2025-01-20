# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=997f6012b540617f7fda1603d169e6ec92be125c"

  cluster_name          = var.cluster_name
  api_servers           = [format("%s.%s", var.cluster_name, var.dns_zone)]
  etcd_servers          = [for fqdn in google_dns_record_set.etcds.*.name : trimsuffix(fqdn, ".")]
  networking            = var.networking
  pod_cidr              = var.pod_cidr
  service_cidr          = var.service_cidr
  daemonset_tolerations = var.daemonset_tolerations
  components            = var.components

  // temporary
  external_apiserver_port = 443
}

