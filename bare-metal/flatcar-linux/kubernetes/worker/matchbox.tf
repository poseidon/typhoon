locals {
  # flatcar-stable -> stable channel
  channel = split("-", var.os_channel)[1]

  remote_kernel = "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe.vmlinuz"
  remote_initrd = [
    "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/amd64-usr/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]
  args = flatten([
    "initrd=flatcar_production_pxe_image.cpio.gz",
    "flatcar.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "flatcar.first_boot=yes",
    var.kernel_args,
  ])

  cached_kernel = "/assets/flatcar/${var.os_version}/flatcar_production_pxe.vmlinuz"
  cached_initrd = [
    "/assets/flatcar/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]

  kernel = var.cached_install ? local.cached_kernel : local.remote_kernel
  initrd = var.cached_install ? local.cached_initrd : local.remote_initrd
}

# Match machine to an install profile by MAC
resource "matchbox_group" "install" {
  name    = format("install-%s", var.name)
  profile = matchbox_profile.install.name
  selector = {
    mac = var.mac
  }
}

// Flatcar Linux install profile (from release.flatcar-linux.net)
resource "matchbox_profile" "install" {
  name   = format("%s-install-%s", var.cluster_name, var.name)
  kernel = local.kernel
  initrd = local.initrd
  args   = concat(local.args, var.kernel_args)

  raw_ignition = data.ct_config.install.rendered
}

# Flatcar Linux install
data "ct_config" "install" {
  content = templatefile("${path.module}/butane/install.yaml", {
    os_channel         = local.channel
    os_version         = var.os_version
    ignition_endpoint  = format("%s/ignition", var.matchbox_http_endpoint)
    mac                = var.mac
    install_disk       = var.install_disk
    ssh_authorized_key = var.ssh_authorized_key
    # only cached profile adds -b baseurl
    baseurl_flag = var.cached_install ? "-b ${var.matchbox_http_endpoint}/assets/flatcar" : ""
  })
  strict = true
}

# Match a worker to a profile by MAC
resource "matchbox_group" "worker" {
  name    = format("%s-%s", var.cluster_name, var.name)
  profile = matchbox_profile.worker.name
  selector = {
    mac = var.mac
    os  = "installed"
  }
}

// Flatcar Linux Worker profile
resource "matchbox_profile" "worker" {
  name         = format("%s-worker-%s", var.cluster_name, var.name)
  raw_ignition = data.ct_config.worker.rendered
}

# Flatcar Linux workers
data "ct_config" "worker" {
  content = templatefile("${path.module}/butane/worker.yaml", {
    domain_name            = var.domain
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
    node_labels            = join(",", var.node_labels)
    node_taints            = join(",", var.node_taints)
    kubeconfig             = var.provision_secrets_with_ignition ? (var.kubeconfig) : "" 
  })
  strict   = true
  snippets = var.snippets
}
