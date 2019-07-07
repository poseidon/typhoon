# Match each controller or worker to a profile

resource "matchbox_group" "controller" {
  count   = length(var.controller_names)
  name    = format("%s-%s", var.cluster_name, var.controller_names[count.index])
  profile = matchbox_profile.controllers.*.name[count.index]

  selector = {
    mac = var.controller_macs[count.index]
  }
}

resource "matchbox_group" "worker" {
  count   = length(var.worker_names)
  name    = format("%s-%s", var.cluster_name, var.worker_names[count.index])
  profile = matchbox_profile.workers.*.name[count.index]

  selector = {
    mac = var.worker_macs[count.index]
  }
}

