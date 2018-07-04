// Install Fedora to disk
resource "matchbox_group" "install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  name    = "${format("fedora-install-%s", element(concat(var.controller_names, var.worker_names), count.index))}"
  profile = "${element(matchbox_profile.cached-fedora-install.*.name, count.index)}"

  selector {
    mac = "${element(concat(var.controller_macs, var.worker_macs), count.index)}"
  }

  metadata {
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}

resource "matchbox_group" "controller" {
  count   = "${length(var.controller_names)}"
  name    = "${format("%s-%s", var.cluster_name, element(var.controller_names, count.index))}"
  profile = "${element(matchbox_profile.controllers.*.name, count.index)}"

  selector {
    mac = "${element(var.controller_macs, count.index)}"
    os  = "installed"
  }
}

resource "matchbox_group" "worker" {
  count   = "${length(var.worker_names)}"
  name    = "${format("%s-%s", var.cluster_name, element(var.worker_names, count.index))}"
  profile = "${element(matchbox_profile.workers.*.name, count.index)}"

  selector {
    mac = "${element(var.worker_macs, count.index)}"
    os  = "installed"
  }
}
