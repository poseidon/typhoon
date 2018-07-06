locals {
  controller_count = "${length(var.controller_names)}"
}

resource "libvirt_volume" "controller-root" {
  count = "${local.controller_count}"

  name           = "${var.cluster_name}-${element(var.controller_names, count.index)}-root"
  base_volume_id = "${libvirt_volume.base.id}"
}

resource "libvirt_ignition" "controller" {
  count = "${local.controller_count}"

  name = "${var.cluster_name}-${element(var.controller_names, count.index)}-ign"
  content = "${element(data.ct_config.controllers.*.rendered, count.index)}"
}

resource "libvirt_domain" "controller" {
  count = "${local.controller_count}"

  name   = "${var.cluster_name}-${element(var.controller_names, count.index)}"
  memory = "${var.controller_memory}"

  coreos_ignition = "${element(libvirt_ignition.controller.*.id, count.index)}"

  disk {
    volume_id = "${element(libvirt_volume.controller-root.*.id, count.index)}"
  }

  network_interface {
    network_id = "${libvirt_network.net.id}"
    hostname   = "${element(var.controller_names, count.index)}"
    # Give controllers stable IPs 
    addresses  = ["${cidrhost(var.node_ip_pool, 10 + count.index)}"]
  }
}
