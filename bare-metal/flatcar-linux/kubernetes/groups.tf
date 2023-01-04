resource "matchbox_group" "install" {
  count = length(var.controllers) + length(var.workers)

  name = format("install-%s", concat(var.controllers[*].name, var.workers[*].name)[count.index])

  # pick Matchbox profile (Flatcar upstream or Matchbox image cache)
  profile = var.cached_install ? matchbox_profile.cached-flatcar-install[count.index].name : matchbox_profile.flatcar-install[count.index].name

  selector = {
    mac = concat(var.controllers[*].mac, var.workers[*].mac)[count.index]
  }
}

resource "matchbox_group" "controller" {
  count   = length(var.controllers)
  name    = format("%s-%s", var.cluster_name, var.controllers[count.index].name)
  profile = matchbox_profile.controllers[count.index].name

  selector = {
    mac = var.controllers[count.index].mac
    os  = "installed"
  }
}

resource "matchbox_group" "worker" {
  count   = length(var.workers)
  name    = format("%s-%s", var.cluster_name, var.workers[count.index].name)
  profile = matchbox_profile.workers[count.index].name

  selector = {
    mac = var.workers[count.index].mac
    os  = "installed"
  }
}

