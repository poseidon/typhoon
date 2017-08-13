// Install Container Linux to disk
resource "matchbox_group" "container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  name    = "${format("container-linux-install-%s", element(concat(var.controller_names, var.worker_names), count.index))}"
  profile = "${var.cached_install == "true" ? matchbox_profile.cached-container-linux-install.name : matchbox_profile.container-linux-install.name}"

  selector {
    mac = "${element(concat(var.controller_macs, var.worker_macs), count.index)}"
  }

  metadata {
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}

resource "matchbox_group" "controller" {
  count   = "${length(var.controller_names)}"
  name    = "${format("%s-%s", var.cluster_name, element(var.controller_names, count.index))}"
  profile = "${matchbox_profile.controller.name}"

  selector {
    mac = "${element(var.controller_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name          = "${element(var.controller_domains, count.index)}"
    etcd_name            = "${element(var.controller_names, count.index)}"
    etcd_initial_cluster = "${join(",", formatlist("%s=https://%s:2380", var.controller_names, var.controller_domains))}"
    etcd_on_host         = "${var.experimental_self_hosted_etcd ? "false" : "true"}"
    k8s_dns_service_ip   = "${module.bootkube.kube_dns_service_ip}"
    ssh_authorized_key   = "${var.ssh_authorized_key}"
  }
}

resource "matchbox_group" "worker" {
  count   = "${length(var.worker_names)}"
  name    = "${format("%s-%s", var.cluster_name, element(var.worker_names, count.index))}"
  profile = "${matchbox_profile.worker.name}"

  selector {
    mac = "${element(var.worker_macs, count.index)}"
    os  = "installed"
  }

  metadata {
    domain_name        = "${element(var.worker_domains, count.index)}"
    etcd_on_host       = "${var.experimental_self_hosted_etcd ? "false" : "true"}"
    k8s_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}
