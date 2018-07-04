locals {
  default_assets_endpoint = "${var.matchbox_http_endpoint}/assets/fedora/28"
  atomic_assets_endpoint  = "${var.atomic_assets_endpoint != "" ? var.atomic_assets_endpoint : local.default_assets_endpoint}"
}

// Cached Fedora Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded Fedora kernel, initrd, and repo into
// matchbox assets.
resource "matchbox_profile" "cached-fedora-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-cached-fedora-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "${local.atomic_assets_endpoint}/images/pxeboot/vmlinuz"

  initrd = [
    "${local.atomic_assets_endpoint}/images/pxeboot/initrd.img",
  ]

  args = [
    "initrd=initrd.img",
    "inst.repo=${local.atomic_assets_endpoint}",
    "inst.ks=${var.matchbox_http_endpoint}/generic?mac=${element(concat(var.controller_macs, var.worker_macs), count.index)}",
    "inst.text",
    "${var.kernel_args}",
  ]

  # kickstart
  generic_config = "${element(data.template_file.install-kickstarts.*.rendered, count.index)}"
}

data "template_file" "install-kickstarts" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  template = "${file("${path.module}/kickstart/fedora-atomic.ks.tmpl")}"

  vars {
    matchbox_http_endpoint = "${var.matchbox_http_endpoint}"
    atomic_assets_endpoint = "${local.atomic_assets_endpoint}"
    mac                    = "${element(concat(var.controller_macs, var.worker_macs), count.index)}"
  }
}

// Kubernetes Controller profiles
resource "matchbox_profile" "controllers" {
  count = "${length(var.controller_names)}"
  name  = "${format("%s-controller-%s", var.cluster_name, element(var.controller_names, count.index))}"

  # cloud-init
  generic_config = "${element(data.template_file.controller-configs.*.rendered, count.index)}"
}

data "template_file" "controller-configs" {
  count = "${length(var.controller_names)}"

  template = "${file("${path.module}/cloudinit/controller.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.controller_domains, count.index)}"
    etcd_name             = "${element(var.controller_names, count.index)}"
    etcd_initial_cluster  = "${join(",", formatlist("%s=https://%s:2380", var.controller_names, var.controller_domains))}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
  }
}

// Kubernetes Worker profiles
resource "matchbox_profile" "workers" {
  count = "${length(var.worker_names)}"
  name  = "${format("%s-worker-%s", var.cluster_name, element(var.worker_names, count.index))}"

  # cloud-init
  generic_config = "${element(data.template_file.worker-configs.*.rendered, count.index)}"
}

data "template_file" "worker-configs" {
  count = "${length(var.worker_names)}"

  template = "${file("${path.module}/cloudinit/worker.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.worker_domains, count.index)}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
  }
}
