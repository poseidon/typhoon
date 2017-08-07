// Container Linux Install profile (from release.core-os.net)
resource "matchbox_profile" "container-linux-install" {
  name   = "container-linux-install"
  kernel = "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${data.template_file.container-linux-install-config.rendered}"
}

data "template_file" "container-linux-install-config" {
  template = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"

  vars {
    container_linux_channel = "${var.container_linux_channel}"
    container_linux_version = "${var.container_linux_version}"
    ignition_endpoint       = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk            = "${var.install_disk}"
    container_linux_oem     = "${var.container_linux_oem}"

    # only cached-container-linux profile adds -b baseurl
    baseurl_flag = ""
  }
}

// Container Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded container_linux_version into matchbox assets.
resource "matchbox_profile" "cached-container-linux-install" {
  name   = "cached-container-linux-install"
  kernel = "/assets/coreos/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${data.template_file.cached-container-linux-install-config.rendered}"
}

data "template_file" "cached-container-linux-install-config" {
  template = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"

  vars {
    container_linux_channel = "${var.container_linux_channel}"
    container_linux_version = "${var.container_linux_version}"
    ignition_endpoint       = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk            = "${var.install_disk}"
    container_linux_oem     = "${var.container_linux_oem}"

    # profile uses -b baseurl to install from matchbox cache
    baseurl_flag = "-b ${var.matchbox_http_endpoint}/assets/coreos"
  }
}

// Kubernetes Controller profile
resource "matchbox_profile" "controller" {
  name                   = "controller"
  container_linux_config = "${file("${path.module}/cl/controller.yaml.tmpl")}"
}

// Kubernetes Worker profile
resource "matchbox_profile" "worker" {
  name                   = "worker"
  container_linux_config = "${file("${path.module}/cl/worker.yaml.tmpl")}"
}
