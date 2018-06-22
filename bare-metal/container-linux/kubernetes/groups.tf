resource "matchbox_group" "install" {
  count = "${length(var.controller_names) + length(var.worker_names)}"

  name = "${format("install-%s", element(concat(var.controller_names, var.worker_names), count.index))}"

  profile = "${local.flavor == "flatcar" ? element(matchbox_profile.flatcar-install.*.name, count.index) : var.cached_install == "true" ? element(matchbox_profile.cached-container-linux-install.*.name, count.index) : element(matchbox_profile.container-linux-install.*.name, count.index)}"

  selector {
    mac = "${element(concat(var.controller_macs, var.worker_macs), count.index)}"
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
