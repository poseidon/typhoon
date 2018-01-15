# Self-hosted Kubernetes assets (kubeconfig, manifests)
data "template_file" "etcd_dns_names" {
  count    = "${var.controller_count}"
  template = "$${node_name}.$${service}.service.$${datacenter}.consul"

  vars {
    node_name  = "${count.index}"
    service    = "etcd"
    datacenter = "${lower(var.region)}"
  }
}

output "test" {
  value = "${module.loadbalancers.public_ipv4_dns}"
}

module "bootkube" {
  source = "git::https://github.com/poseidon/terraform-render-bootkube.git?ref=b83e321b350ac549c45ed6a05ffd8683336fb9f4"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${coalescelist( compact(list(var.dns_zone != "" ? format("%s.%s", local.api_dns_subdomain, var.dns_zone) : "" )), module.loadbalancers.public_ipv4_dns)}"]
  etcd_servers          = ["${data.template_file.etcd_dns_names.*.rendered}"]
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
}
