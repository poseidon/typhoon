# Match each controller or worker to a profile

resource "matchbox_group" "controller" {
  count   = length(var.controllers)
  name    = format("%s-%s", var.cluster_name, var.controllers[count.index].name)
  profile = matchbox_profile.controllers[count.index].name

  selector = {
    mac = var.controllers[count.index].mac
  }
}

resource "matchbox_group" "worker" {
  count   = length(var.workers)
  name    = format("%s-%s", var.cluster_name, var.workers[count.index].name)
  profile = matchbox_profile.workers[count.index].name

  selector = {
    mac = var.workers[count.index].mac
  }
}

