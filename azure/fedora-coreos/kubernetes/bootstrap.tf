# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=0b78c87997ff96547773e878458ec95485c8b91f"

  cluster_name = var.cluster_name
  api_servers  = [format("%s.%s", var.cluster_name, var.dns_zone)]
  etcd_servers = formatlist("%s.%s", azurerm_dns_a_record.etcds.*.name, var.dns_zone)

  networking = var.networking
  # only effective with Calico networking
  # we should be able to use 1450 MTU, but in practice, 1410 was needed
  network_encapsulation = "vxlan"
  network_mtu           = "1410"

  pod_cidr              = var.pod_cidr
  service_cidr          = var.service_cidr
  daemonset_tolerations = var.daemonset_tolerations
  components            = var.components
}

