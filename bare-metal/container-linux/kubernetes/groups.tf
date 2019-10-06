resource "matchbox_group" "install" {
  count = length(var.controllers) + length(var.workers)

  name = format("install-%s", concat(var.controllers.*.name, var.workers.*.name)[count.index])

  # pick one of 4 Matchbox profiles (Container Linux or Flatcar, cached or non-cached)
  profile = local.flavor == "flatcar" ? var.cached_install ? matchbox_profile.cached-flatcar-linux-install.*.name[count.index] : matchbox_profile.flatcar-install.*.name[count.index] : var.cached_install ? matchbox_profile.cached-container-linux-install.*.name[count.index] : matchbox_profile.container-linux-install.*.name[count.index]

  selector = {
    mac = concat(var.controllers.*.mac, var.workers.*.mac)[count.index]
  }
}

resource "matchbox_group" "controller" {
  count   = length(var.controllers)
  name    = format("%s-%s", var.cluster_name, var.controllers[count.index].name)
  profile = matchbox_profile.controllers.*.name[count.index]

  selector = {
    mac = var.controllers[count.index].mac
    os  = "installed"
  }
}

resource "matchbox_group" "worker" {
  count   = length(var.workers)
  name    = format("%s-%s", var.cluster_name, var.workers[count.index].name)
  profile = matchbox_profile.workers.*.name[count.index]

  selector = {
    mac = var.workers[count.index].mac
    os  = "installed"
  }
}

