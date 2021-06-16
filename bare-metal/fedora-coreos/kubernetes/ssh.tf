locals {
  # format assets for distribution
  assets_bundle = [
    # header with the unpack location
    for key, value in module.bootstrap.assets_dist :
    format("##### %s\n%s", key, value)
  ]
}

# Secure copy assets to controllers. Activates kubelet.service
resource "null_resource" "copy-controller-secrets" {
  count = length(var.controllers)

  # Without depends_on, remote-exec could start and wait for machines before
  # matchbox groups are written, causing a deadlock.
  depends_on = [
    matchbox_group.controller,
    matchbox_group.worker,
    module.bootstrap,
  ]

  connection {
    type    = "ssh"
    host    = var.controllers.*.domain[count.index]
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = module.bootstrap.kubeconfig-kubelet
    destination = "$HOME/kubeconfig"
  }

  provisioner "file" {
    content     = join("\n", local.assets_bundle)
    destination = "$HOME/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv $HOME/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo touch /etc/kubernetes",
      "sudo /opt/bootstrap/layout",
    ]
  }
}

# Secure copy kubeconfig to all workers. Activates kubelet.service
resource "null_resource" "copy-worker-secrets" {
  count = length(var.workers)

  # Without depends_on, remote-exec could start and wait for machines before
  # matchbox groups are written, causing a deadlock.
  depends_on = [
    matchbox_group.controller,
    matchbox_group.worker,
  ]

  connection {
    type    = "ssh"
    host    = var.workers.*.domain[count.index]
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = module.bootstrap.kubeconfig-kubelet
    destination = "$HOME/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv $HOME/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo touch /etc/kubernetes",
    ]
  }
}

# Connect to a controller to perform one-time cluster bootstrap.
resource "null_resource" "bootstrap" {
  # Without depends_on, this remote-exec may start before the kubeconfig copy.
  # Terraform only does one task at a time, so it would try to bootstrap
  # while no Kubelets are running.
  depends_on = [
    null_resource.copy-controller-secrets,
    null_resource.copy-worker-secrets,
  ]

  connection {
    type    = "ssh"
    host    = var.controllers[0].domain
    user    = "core"
    timeout = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}


