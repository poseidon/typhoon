# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=05297b94a936c356851e180e4963034e0047e1c0"

  cluster_name          = var.cluster_name
  api_servers           = [format("%s.%s", var.cluster_name, var.dns_zone)]
  etcd_servers          = google_dns_record_set.etcds.*.name
  asset_dir             = var.asset_dir
  networking            = var.networking
  network_mtu           = 1440
  pod_cidr              = var.pod_cidr
  service_cidr          = var.service_cidr
  cluster_domain_suffix = var.cluster_domain_suffix
  enable_reporting      = var.enable_reporting
  enable_aggregation    = var.enable_aggregation

  trusted_certs_dir = "/etc/pki/tls/certs"

  // temporary
  external_apiserver_port = 443
}

