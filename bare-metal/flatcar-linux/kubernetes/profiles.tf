locals {
  # coreos-stable -> coreos flavor, stable channel
  # flatcar-stable -> flatcar flavor, stable channel
  flavor  = split("-", var.os_channel)[0]
  channel = split("-", var.os_channel)[1]
}

// Container Linux Install profile (from release.core-os.net)
resource "matchbox_profile" "container-linux-install" {
  count = length(var.controllers) + length(var.workers)
  name  = format("%s-container-linux-install-%s", var.cluster_name, concat(var.controllers.*.name, var.workers.*.name)[count.index])

  kernel = "${var.download_protocol}://${local.channel}.release.core-os.net/amd64-usr/${var.os_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "${var.download_protocol}://${local.channel}.release.core-os.net/amd64-usr/${var.os_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = flatten([
    "initrd=coreos_production_pxe_image.cpio.gz",
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    var.kernel_args,
  ])

  container_linux_config = data.template_file.container-linux-install-configs.*.rendered[count.index]
}

data "template_file" "container-linux-install-configs" {
  count = length(var.controllers) + length(var.workers)

  template = file("${path.module}/cl/install.yaml")

  vars = {
    os_flavor          = local.flavor
    os_channel         = local.channel
    os_version         = var.os_version
    ignition_endpoint  = format("%s/ignition", var.matchbox_http_endpoint)
    install_disk       = var.install_disk
    ssh_authorized_key = var.ssh_authorized_key
    # only cached-container-linux profile adds -b baseurl
    baseurl_flag = ""
  }
}

// Container Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded os_version into matchbox assets/coreos.
resource "matchbox_profile" "cached-container-linux-install" {
  count = length(var.controllers) + length(var.workers)
  name  = format("%s-cached-container-linux-install-%s", var.cluster_name, concat(var.controllers.*.name, var.workers.*.name)[count.index])

  kernel = "/assets/coreos/${var.os_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.os_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = flatten([
    "initrd=coreos_production_pxe_image.cpio.gz",
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    var.kernel_args,
  ])

  container_linux_config = data.template_file.cached-container-linux-install-configs.*.rendered[count.index]
}

data "template_file" "cached-container-linux-install-configs" {
  count = length(var.controllers) + length(var.workers)

  template = file("${path.module}/cl/install.yaml")

  vars = {
    os_flavor          = local.flavor
    os_channel         = local.channel
    os_version         = var.os_version
    ignition_endpoint  = format("%s/ignition", var.matchbox_http_endpoint)
    install_disk       = var.install_disk
    ssh_authorized_key = var.ssh_authorized_key
    # profile uses -b baseurl to install from matchbox cache
    baseurl_flag = "-b ${var.matchbox_http_endpoint}/assets/${local.flavor}"
  }
}

// Flatcar Linux install profile (from release.flatcar-linux.net)
resource "matchbox_profile" "flatcar-install" {
  count = length(var.controllers) + length(var.workers)
  name  = format("%s-flatcar-install-%s", var.cluster_name, concat(var.controllers.*.name, var.workers.*.name)[count.index])

  kernel = "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe.vmlinuz"

  initrd = [
    "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]

  args = flatten([
    "initrd=flatcar_production_pxe_image.cpio.gz",
    "flatcar.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "flatcar.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    var.kernel_args,
  ])

  container_linux_config = data.template_file.container-linux-install-configs.*.rendered[count.index]
}

// Flatcar Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded os_version into matchbox assets/flatcar.
resource "matchbox_profile" "cached-flatcar-linux-install" {
  count = length(var.controllers) + length(var.workers)
  name  = format("%s-cached-flatcar-linux-install-%s", var.cluster_name, concat(var.controllers.*.name, var.workers.*.name)[count.index])

  kernel = "/assets/flatcar/${var.os_version}/flatcar_production_pxe.vmlinuz"

  initrd = [
    "/assets/flatcar/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]

  args = flatten([
    "initrd=flatcar_production_pxe_image.cpio.gz",
    "flatcar.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "flatcar.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    var.kernel_args,
  ])

  container_linux_config = data.template_file.cached-container-linux-install-configs.*.rendered[count.index]
}

// Kubernetes Controller profiles
resource "matchbox_profile" "controllers" {
  count        = length(var.controllers)
  name         = format("%s-controller-%s", var.cluster_name, var.controllers.*.name[count.index])
  raw_ignition = data.ct_config.controller-ignitions.*.rendered[count.index]
}

data "ct_config" "controller-ignitions" {
  count    = length(var.controllers)
  content  = data.template_file.controller-configs.*.rendered[count.index]
  strict   = true
  snippets = lookup(var.snippets, var.controllers.*.name[count.index], [])
}

data "template_file" "controller-configs" {
  count = length(var.controllers)

  template = file("${path.module}/cl/controller.yaml")

  vars = {
    domain_name            = var.controllers.*.domain[count.index]
    etcd_name              = var.controllers.*.name[count.index]
    etcd_initial_cluster   = join(",", formatlist("%s=https://%s:2380", var.controllers.*.name, var.controllers.*.domain))
    cgroup_driver          = var.os_channel == "flatcar-edge" ? "systemd" : "cgroupfs"
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
  }
}

// Kubernetes Worker profiles
resource "matchbox_profile" "workers" {
  count        = length(var.workers)
  name         = format("%s-worker-%s", var.cluster_name, var.workers.*.name[count.index])
  raw_ignition = data.ct_config.worker-ignitions.*.rendered[count.index]
}

data "ct_config" "worker-ignitions" {
  count    = length(var.workers)
  content  = data.template_file.worker-configs.*.rendered[count.index]
  strict   = true
  snippets = lookup(var.snippets, var.workers.*.name[count.index], [])
}

data "template_file" "worker-configs" {
  count = length(var.workers)

  template = file("${path.module}/cl/worker.yaml")

  vars = {
    domain_name            = var.workers.*.domain[count.index]
    cgroup_driver          = var.os_channel == "flatcar-edge" ? "systemd" : "cgroupfs"
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
    node_labels            = join(",", lookup(var.worker_node_labels, var.workers.*.name[count.index], []))
    node_taints            = join(",", lookup(var.worker_node_taints, var.workers.*.name[count.index], []))
  }
}
