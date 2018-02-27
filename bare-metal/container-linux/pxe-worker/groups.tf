resource "matchbox_group" "workers" {
  count   = "${length(var.worker_names)}"
  name    = "${format("%s-%s", var.cluster_name, element(var.worker_names, count.index))}"
  profile = "${matchbox_profile.bootkube-worker-pxe.name}"

  selector {
    mac = "${element(var.worker_macs, count.index)}"
  }

  metadata {
    pxe            = "true"
    domain_name    = "${element(var.worker_domains, count.index)}"
    etcd_endpoints = "${join(",", formatlist("%s:2379", var.controller_domains))}"

    k8s_dns_service_ip    = "${var.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
  }
}
