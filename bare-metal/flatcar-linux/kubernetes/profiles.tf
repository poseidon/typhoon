locals {
  # flatcar-stable -> stable channel
  channel = split("-", var.os_channel)[1]
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
    var.kernel_args,
  ])

  raw_ignition = data.ct_config.install.*.rendered[count.index]
}

// Flatcar Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded os_version into matchbox assets/flatcar.
resource "matchbox_profile" "cached-flatcar-install" {
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
    var.kernel_args,
  ])

  raw_ignition = data.ct_config.cached-install.*.rendered[count.index]
}

# Flatcar Linux install
data "ct_config" "install" {
  count = length(var.controllers) + length(var.workers)
  content = templatefile("${path.module}/butane/install.yaml", {
    os_channel         = local.channel
    os_version         = var.os_version
    ignition_endpoint  = format("%s/ignition", var.matchbox_http_endpoint)
    mac                = concat(var.controllers.*.mac, var.workers.*.mac)[count.index]
    install_disk       = concat(var.controllers.*.install_disk, var.workers.*.install_disk)[count.index]
    ssh_authorized_key = var.ssh_authorized_key
    # only cached profile adds -b baseurl
    baseurl_flag = ""
  })
  strict = true
}

# Flatcar Linux cached install
data "ct_config" "cached-install" {
  count = length(var.controllers) + length(var.workers)
  content = templatefile("${path.module}/butane/install.yaml", {
    os_channel         = local.channel
    os_version         = var.os_version
    ignition_endpoint  = format("%s/ignition", var.matchbox_http_endpoint)
    mac                = concat(var.controllers.*.mac, var.workers.*.mac)[count.index]
    install_disk       = concat(var.controllers.*.install_disk, var.workers.*.install_disk)[count.index]
    ssh_authorized_key = var.ssh_authorized_key
    # profile uses -b baseurl to install from matchbox cache
    baseurl_flag = "-b ${var.matchbox_http_endpoint}/assets/flatcar"
  })
  strict = true
}

// Kubernetes Controller profiles
resource "matchbox_profile" "controllers" {
  count        = length(var.controllers)
  name         = format("%s-controller-%s", var.cluster_name, var.controllers.*.name[count.index])
  raw_ignition = data.ct_config.controllers.*.rendered[count.index]
}

# Flatcar Linux controllers
data "ct_config" "controllers" {
  count = length(var.controllers)
  content = templatefile("${path.module}/butane/controller.yaml", {
    domain_name            = var.controllers.*.domain[count.index]
    etcd_name              = var.controllers.*.name[count.index]
    etcd_initial_cluster   = join(",", formatlist("%s=https://%s:2380", var.controllers.*.name, var.controllers.*.domain))
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
  })
  strict   = true
  snippets = lookup(var.snippets, var.controllers.*.name[count.index], [])
}

// Kubernetes Worker profiles
resource "matchbox_profile" "workers" {
  count        = length(var.workers)
  name         = format("%s-worker-%s", var.cluster_name, var.workers.*.name[count.index])
  raw_ignition = data.ct_config.workers.*.rendered[count.index]
}

# Flatcar Linux workers
data "ct_config" "workers" {
  count = length(var.workers)
  content = templatefile("${path.module}/butane/worker.yaml", {
    domain_name            = var.workers.*.domain[count.index]
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
    node_labels            = join(",", lookup(var.worker_node_labels, var.workers.*.name[count.index], []))
    node_taints            = join(",", lookup(var.worker_node_taints, var.workers.*.name[count.index], []))
  })
  strict   = true
  snippets = lookup(var.snippets, var.workers.*.name[count.index], [])
}
