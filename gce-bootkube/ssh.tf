# Secure copy bootkube assets to ONE controller and start bootkube to perform
# one-time self-hosted cluster bootstrapping.
resource "null_resource" "bootkube-start" {
  depends_on = ["module.controllers", "module.workers", "module.bootkube"]

  # TODO: SSH to a controller's IP instead of waiting on DNS resolution
  connection {
    type    = "ssh"
    host    = "${var.k8s_domain_name}"
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
