locals {
  # coreos-stable -> coreos flavor, stable channel
  # flatcar-stable -> flatcar flavor, stable channel
  flavor = "${element(split("-", var.os_channel), 0)}"

  channel = "${element(split("-", var.os_channel), 1)}"
}

// Container Linux Install profile (from release.core-os.net)
resource "matchbox_profile" "container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-container-linux-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "http://${local.channel}.release.core-os.net/amd64-usr/${var.os_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "http://${local.channel}.release.core-os.net/amd64-usr/${var.os_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "initrd=coreos_production_pxe_image.cpio.gz",
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "${var.kernel_args}",
  ]

  container_linux_config = "${element(data.template_file.container-linux-install-configs.*.rendered, count.index)}"
}

data "template_file" "container-linux-install-configs" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  template = "${file("${path.module}/cl/install.yaml.tmpl")}"

  vars {
    os_flavor           = "${local.flavor}"
    os_channel          = "${local.channel}"
    os_version          = "${var.os_version}"
    ignition_endpoint   = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk        = "${var.install_disk}"
    container_linux_oem = "${var.container_linux_oem}"
    ssh_authorized_key  = "${var.ssh_authorized_key}"

    # only cached-container-linux profile adds -b baseurl
    baseurl_flag = ""
  }
}

// Container Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded os_version into matchbox assets.
resource "matchbox_profile" "cached-container-linux-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-cached-container-linux-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "/assets/coreos/${var.os_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.os_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "initrd=coreos_production_pxe_image.cpio.gz",
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "${var.kernel_args}",
  ]

  container_linux_config = "${element(data.template_file.cached-container-linux-install-configs.*.rendered, count.index)}"
}

data "template_file" "cached-container-linux-install-configs" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  template = "${file("${path.module}/cl/install.yaml.tmpl")}"

  vars {
    os_flavor           = "${local.flavor}"
    os_channel          = "${local.channel}"
    os_version          = "${var.os_version}"
    ignition_endpoint   = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk        = "${var.install_disk}"
    container_linux_oem = "${var.container_linux_oem}"
    ssh_authorized_key  = "${var.ssh_authorized_key}"

    # profile uses -b baseurl to install from matchbox cache
    baseurl_flag = "-b ${var.matchbox_http_endpoint}/assets/coreos"
  }
}

// Flatcar Linux install profile (from release.flatcar-linux.net)
resource "matchbox_profile" "flatcar-install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"
  name  = "${format("%s-flatcar-install-%s", var.cluster_name, element(concat(var.controller_names, var.worker_names), count.index))}"

  kernel = "http://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe.vmlinuz"

  initrd = [
    "http://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]

  args = [
    "initrd=flatcar_production_pxe_image.cpio.gz",
    "flatcar.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "flatcar.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "${var.kernel_args}",
  ]

  container_linux_config = "${element(data.template_file.container-linux-install-configs.*.rendered, count.index)}"
}

// Kubernetes Controller profiles
resource "matchbox_profile" "controllers" {
  count        = "${length(var.controller_names)}"
  name         = "${format("%s-controller-%s", var.cluster_name, element(var.controller_names, count.index))}"
  raw_ignition = "${element(data.ct_config.controller-ignitions.*.rendered, count.index)}"
}

data "ct_config" "controller-ignitions" {
  count        = "${length(var.controller_names)}"
  content      = "${element(data.template_file.controller-configs.*.rendered, count.index)}"
  pretty_print = false

  # Must use direct lookup. Cannot use lookup(map, key) since it only works for flat maps
  snippets = ["${local.clc_map[element(var.controller_names, count.index)]}"]
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
  }
}

// Kubernetes Worker profiles
resource "matchbox_profile" "workers" {
  count        = "${length(var.worker_names)}"
  name         = "${format("%s-worker-%s", var.cluster_name, element(var.worker_names, count.index))}"
  raw_ignition = "${element(data.ct_config.worker-ignitions.*.rendered, count.index)}"
}

data "ct_config" "worker-ignitions" {
  count        = "${length(var.worker_names)}"
  content      = "${element(data.template_file.worker-configs.*.rendered, count.index)}"
  pretty_print = false

  # Must use direct lookup. Cannot use lookup(map, key) since it only works for flat maps
  snippets = ["${local.clc_map[element(var.worker_names, count.index)]}"]
}

data "template_file" "worker-configs" {
  count = "${length(var.worker_names)}"

  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars {
    domain_name           = "${element(var.worker_domains, count.index)}"
    k8s_dns_service_ip    = "${module.bootkube.kube_dns_service_ip}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
  }
}

locals {
  # Hack to workaround https://github.com/hashicorp/terraform/issues/17251
  # Default Container Linux config snippets map every node names to list("\n") so
  # all lookups succeed
  clc_defaults = "${zipmap(concat(var.controller_names, var.worker_names), chunklist(data.template_file.clc-default-snippets.*.rendered, 1))}"

  # Union of the default and user specific snippets, later overrides prior.
  clc_map = "${merge(local.clc_defaults, var.clc_snippets)}"
}

// Horrible hack to generate a Terraform list of node count length
data "template_file" "clc-default-snippets" {
  count    = "${length(var.controller_names) + length(var.worker_names)}"
  template = "\n"
}
