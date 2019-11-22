# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=0f1f16c612a6877d25a3fedcb476b3087a3de999"

  cluster_name = var.cluster_name
  api_servers  = [format("%s.%s", var.cluster_name, var.dns_zone)]
  etcd_servers = formatlist("%s.%s", azurerm_dns_a_record.etcds.*.name, var.dns_zone)
  asset_dir    = var.asset_dir

  networking = var.networking

  # only effective with Calico networking
  # we should be able to use 1450 MTU, but in practice, 1410 was needed
  network_encapsulation = "vxlan"
  network_mtu           = "1410"

  pod_cidr              = var.pod_cidr
  service_cidr          = var.service_cidr
  cluster_domain_suffix = var.cluster_domain_suffix
  enable_reporting      = var.enable_reporting
  enable_aggregation    = var.enable_aggregation
}

