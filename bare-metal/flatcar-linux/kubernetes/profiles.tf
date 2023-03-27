locals {
  # flatcar-stable -> stable channel
  channel = split("-", var.os_channel)[1]

  remote_kernel = "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe.vmlinuz"
  remote_initrd = [
    "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]
  args = [
    "initrd=flatcar_production_pxe_image.cpio.gz",
    "flatcar.config.url=${var.matchbox_http_endpoint}/ignition?$${extra_selectors}mac=$${mac:hexhyp}",
    "flatcar.first_boot=yes",
  ]

  cached_kernel = "/assets/flatcar/${var.os_version}/flatcar_production_pxe.vmlinuz"
  cached_initrd = [
    "/assets/flatcar/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]

  kernel = var.cached_install ? local.cached_kernel : local.remote_kernel
  initrd = var.cached_install ? local.cached_initrd : local.remote_initrd
}

# Match controllers to install profiles by MAC
resource "matchbox_group" "install" {
  count = length(var.controllers)

  name    = format("install-%s", var.controllers[count.index].name)
  profile = matchbox_profile.install[count.index].name
  selector = {
    mac             = concat(var.controllers.*.mac, var.workers.*.mac)[count.index]
    extra_selectors = "${concat([for key, value in var.controllers.*.extra_selectors : "${urlencode(key)}=${urlencode(value)}&"])}${concat([for key, value in var.workers.*.extra_selectors : "${urlencode(key)}=${urlencode(value)}&"])}"
  }
}

// Flatcar Linux install
resource "matchbox_profile" "install" {
  count = length(var.controllers)

  name   = format("%s-install-%s", var.cluster_name, var.controllers.*.name[count.index])
  kernel = local.kernel
  initrd = local.initrd
  args   = concat(local.args, var.kernel_args)

  raw_ignition = data.ct_config.install[count.index].rendered
}

# Flatcar Linux install
data "ct_config" "install" {
  count = length(var.controllers)

  content = templatefile("${path.module}/butane/install.yaml", {
    os_channel         = local.channel
    os_version         = var.os_version
    ignition_endpoint  = format("%s/ignition", var.matchbox_http_endpoint)
    mac                = concat(var.controllers.*.mac, var.workers.*.mac)[count.index]
    extra_selectors    = "${concat([for key, value in var.controllers.*.extra_selectors : "${urlencode(key)}=${urlencode(value)}&"])}${concat([for key, value in var.workers.*.extra_selectors : "${urlencode(key)}=${urlencode(value)}&"])}"
    install_disk       = var.install_disk
    ssh_authorized_key = var.ssh_authorized_key
    # only cached profile adds -b baseurl
    baseurl_flag = var.cached_install ? "-b ${var.matchbox_http_endpoint}/assets/flatcar" : ""
  })
  strict = true
}

# Match each controller by MAC
resource "matchbox_group" "controller" {
  count   = length(var.controllers)
  name    = format("%s-%s", var.cluster_name, var.controllers[count.index].name)
  profile = matchbox_profile.controllers[count.index].name
  selector = {
    mac             = var.controllers[count.index].mac
    extra_selectors = concat([for key, value in var.controllers.*.extra_selectors : "${urlencode(key)}=${urlencode(value)}&"])
    os              = "installed"
  }
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
    etcd_initial_cluster   = join("", formatlist("%s=https://%s:2380", var.controllers.*.name, var.controllers.*.domain))
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
  })
  strict   = true
  snippets = lookup(var.snippets, var.controllers.*.name[count.index], [])
}
