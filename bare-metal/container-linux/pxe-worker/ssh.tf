# Secure copy kubeconfig to all nodes to activate kubelet.service
resource "null_resource" "copy-kubeconfig" {
  count = "${length(var.worker_names)}"

  connection {
    type    = "ssh"
    host    = "${element(var.worker_domains, count.index)}"
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = "${var.kubeconfig}"
    destination = "$HOME/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
    ]
  }
}
