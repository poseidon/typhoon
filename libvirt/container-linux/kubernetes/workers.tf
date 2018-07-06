locals {
  worker_count = "${length(var.worker_names)}"
}

resource "libvirt_volume" "worker-root" {
  count = "${local.worker_count}"

  name           = "${var.cluster_name}-${element(var.worker_names, count.index)}-root"
  base_volume_id = "${libvirt_volume.base.id}"
}

resource "libvirt_ignition" "worker" {
  count = "${local.worker_count}"

  name = "${var.cluster_name}-${element(var.worker_names, count.index)}-ign"

  content = "${element(data.ct_config.workers.*.rendered, count.index)}"
}

resource "libvirt_domain" "worker" {
  count = "${local.worker_count}"

  name   = "${var.cluster_name}-${element(var.worker_names, count.index)}"
  memory = "${var.worker_memory}"

  coreos_ignition = "${element(libvirt_ignition.worker.*.id, count.index)}"

  disk {
    volume_id = "${element(libvirt_volume.worker-root.*.id, count.index)}"
  }

  network_interface {
    network_id = "${libvirt_network.net.id}"
    hostname   = "${element(var.worker_names, count.index)}"
    wait_for_lease = 1
  }
}
