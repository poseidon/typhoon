# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=8c2e766d180824416075f4d7a695d6291ef277ab"

  cluster_name          = var.cluster_name
  api_servers           = [format("%s.%s", var.cluster_name, var.dns_zone)]
  etcd_servers          = google_dns_record_set.etcds.*.name
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

