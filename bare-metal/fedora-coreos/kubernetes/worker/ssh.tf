# Secure copy kubeconfig to worker. Activates kubelet.service
resource "null_resource" "copy-worker-secrets" {
  # Without depends_on, remote-exec could start and wait for machines before
  # matchbox groups are written, causing a deadlock.
  depends_on = [
    matchbox_group.worker,
  ]

  connection {
    type    = "ssh"
    host    = var.domain
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = var.kubeconfig
    destination = "/home/core/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo touch /etc/kubernetes",
    ]
  }
}
