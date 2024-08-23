# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=0b78c87997ff96547773e878458ec95485c8b91f"

  cluster_name          = var.cluster_name
  api_servers           = [format("%s.%s", var.cluster_name, var.dns_zone)]
  etcd_servers          = aws_route53_record.etcds.*.fqdn
  networking            = var.networking
  network_mtu           = var.network_mtu
  pod_cidr              = var.pod_cidr
  service_cidr          = var.service_cidr
  daemonset_tolerations = var.daemonset_tolerations
  components            = var.components
}

