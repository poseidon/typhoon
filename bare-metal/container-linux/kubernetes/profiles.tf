locals {
  flavor  = "${element(split("-", var.os_channel), 0)}"
  channel = "${element(split("-", var.os_channel), 1)}"

  profile      = "${local.flavor == "flatcar" ? "fl" : "cl"}"
  install_tmpl = "${local.flavor == "flatcar" ? "flatcar-linux-install.yaml.tmpl" : "container-linux-install.yaml.tmpl"}"

  url_base = "${local.flavor == "flatcar" ? "http://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}" : "http://${local.channel}.release.core-os.net/amd64-usr/${var.os_version}"}"

  kernel_filename = "${local.flavor}_production_pxe.vmlinuz"
  initrd_filename = "${local.flavor}_production_pxe_image.cpio.gz"

  kernel_url = "${local.url_base}/${local.kernel_filename}"
  initrd_url = "${local.url_base}/${local.initrd_filename}"

  kernel_assets = "/assets/${local.flavor}/${var.os_version}/${local.kernel_filename}"
  initrd_assets = "/assets/${local.flavor}/${var.os_version}/${local.initrd_filename}"

  template_yaml = "${file("${path.module}/${local.profile}/${local.install_tmpl}")}"
}

// Container Linux Install profile (from release.core-os.net)
resource "matchbox_profile" "container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-container-linux-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "${local.kernel_url}"

  initrd = [
    "${local.initrd_url}",
  ]

  args = [
    "initrd=${local.linux_initrd}",
    "${local.flavor}.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "${local.flavor}.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "${var.kernel_args}",
  ]

  container_linux_config = "${element(data.template_file.container-linux-install-configs.*.rendered, count.index)}"
}

data "template_file" "container-linux-install-configs" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  template = "${local.template_yaml}"

  vars {
    os_channel              = "${local.channel}"
    os_version              = "${var.os_version}"
    ignition_endpoint       = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk            = "${var.install_disk}"
    container_linux_oem     = "${var.container_linux_oem}"
    ssh_authorized_key      = "${var.ssh_authorized_key}"

    # only cached-container-linux profile adds -b baseurl
    baseurl_flag = ""
  }
}

// Container Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded os_version into matchbox assets.
resource "matchbox_profile" "cached-container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-cached-container-linux-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "${local.kernel_assets}"

  initrd = [
    "${local.initrd_assets}",
  ]

  args = [
    "initrd=${local.linux_initrd}",
    "${local.flavor}.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "${local.flavor}.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "${var.kernel_args}",
  ]

  container_linux_config = "${element(data.template_file.cached-container-linux-install-configs.*.rendered, count.index)}"
}

data "template_file" "cached-container-linux-install-configs" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  template = "${local.template_yaml}"

  vars {
    os_channel              = "${local.channel}"
    os_version              = "${var.os_version}"
    ignition_endpoint       = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk            = "${var.install_disk}"
    container_linux_oem     = "${var.container_linux_oem}"
    ssh_authorized_key      = "${var.ssh_authorized_key}"

    # profile uses -b baseurl to install from matchbox cache
    baseurl_flag = "-b ${var.matchbox_http_endpoint}/assets/${local.flavor}"
  }
}

// Kubernetes Controller profiles
resource "matchbox_profile" "controllers" {
  count                  = "${length(var.controller_names)}"
  name                   = "${format("%s-controller-%s", var.cluster_name, element(var.controller_names, count.index))}"
  container_linux_config = "${element(data.template_file.controller-configs.*.rendered, count.index)}"
}

data "template_file" "controller-configs" {
  count = "${length(var.controller_names)}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.controller_domains, count.index)}"
    etcd_name             = "${element(var.controller_names, count.index)}"
    etcd_initial_cluster  = "${join(",", formatlist("%s=https://%s:2380", var.controller_names, var.controller_domains))}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"

    # Terraform evaluates both sides regardless and element cannot be used on 0 length lists
    networkd_content = "${length(var.controller_networkds) == 0 ? "" : element(concat(var.controller_networkds, list("")), count.index)}"
  }
}

// Kubernetes Worker profiles
resource "matchbox_profile" "workers" {
  count                  = "${length(var.worker_names)}"
  name                   = "${format("%s-worker-%s", var.cluster_name, element(var.worker_names, count.index))}"
  container_linux_config = "${element(data.template_file.worker-configs.*.rendered, count.index)}"
}

data "template_file" "worker-configs" {
  count = "${length(var.worker_names)}"

  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.worker_domains, count.index)}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"

    # Terraform evaluates both sides regardless and element cannot be used on 0 length lists
    networkd_content = "${length(var.worker_networkds) == 0 ? "" : element(concat(var.worker_networkds, list("")), count.index)}"
  }
}
