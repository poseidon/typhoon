# Match each controller or worker to a profile

resource "matchbox_group" "controller" {
  count   = length(var.controllers)
  name    = format("%s-%s", var.cluster_name, var.controllers.*.name[count.index])
  profile = matchbox_profile.controllers.*.name[count.index]

  selector = {
    mac = var.controllers.*.mac[count.index]
  }
}

resource "matchbox_group" "worker" {
  count   = length(var.workers)
  name    = format("%s-%s", var.cluster_name, var.workers.*.name[count.index])
  profile = matchbox_profile.workers.*.name[count.index]

  selector = {
    mac = var.workers.*.mac[count.index]
  }
}

