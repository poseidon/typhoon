# Secure copy kubeconfig to all nodes. Activates kubelet.service
resource "null_resource" "copy-secrets" {
  count = "${var.controller_count + var.worker_count}"

  connection {
    type    = "ssh"
    host    = "${element(concat(digitalocean_droplet.controllers.*.ipv4_address, digitalocean_droplet.workers.*.ipv4_address), count.index)}"
    user    = "core"
    timeout = "15m"
  }

  provisioner "file" {
    content     = "${module.bootkube.kubeconfig}"
    destination = "$HOME/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
    ]
  }
}
  
# Secure copy bootkube assets to ONE controller and start bootkube to perform
# one-time self-hosted cluster bootstrapping.
resource "null_resource" "bootkube-start" {
  depends_on = ["module.bootkube", "null_resource.copy-secrets", "digitalocean_droplet.controllers"]

  connection {
    type    = "ssh"
    host    = "${digitalocean_droplet.controllers.0.ipv4_address}"
    user    = "core"
    timeout = "15m"
  }

  provisioner "file" {
    source      = "${var.asset_dir}"
    destination = "$HOME/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/assets /opt/bootkube",
      "sudo systemctl start bootkube",
    ]
  }
}
