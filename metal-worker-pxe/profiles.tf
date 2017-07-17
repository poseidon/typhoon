// Container Linux Install profile (from release.core-os.net)
resource "matchbox_profile" "bootkube-worker-pxe" {
  name   = "bootkube-worker-pxe"
  kernel = "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "http://${var.container_linux_channel}.release.core-os.net/amd64-usr/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "root=/dev/sda1",
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "kvm-intel.nested=1",
  ]

  container_linux_config = "${file("${path.module}/cl/bootkube-worker.yaml.tmpl")}"
}
