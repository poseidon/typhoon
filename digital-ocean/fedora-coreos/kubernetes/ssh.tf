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
  count = var.controller_count

  depends_on = [
    module.bootstrap,
    digitalocean_firewall.rules
  ]

  connection {
    type    = "ssh"
    host    = digitalocean_droplet.controllers.*.ipv4_address[count.index]
    user    = "core"
    timeout = "15m"
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

# Secure copy kubeconfig to all workers. Activates kubelet.service.
resource "null_resource" "copy-worker-secrets" {
  count = var.worker_count

  connection {
    type    = "ssh"
    host    = digitalocean_droplet.workers.*.ipv4_address[count.index]
    user    = "core"
    timeout = "15m"
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
  depends_on = [
    null_resource.copy-controller-secrets,
    null_resource.copy-worker-secrets,
  ]

  connection {
    type    = "ssh"
    host    = digitalocean_droplet.controllers[0].ipv4_address
    user    = "core"
    timeout = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}
