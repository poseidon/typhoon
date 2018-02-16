# Secure copy etcd TLS assets and kubeconfig to controllers. Activates kubelet.service
resource "null_resource" "copy-secrets" {
  depends_on = ["aws_route53_record.bastion", "aws_route53_record.apiserver", "aws_autoscaling_group.bastion", "aws_autoscaling_attachment.bastion_tg_attachment", "aws_lb_listener.bastion-22"]
  count = "${var.controller_count}"

  connection {
    agent = false
    type    = "ssh"
    host    = "${element(aws_instance.controllers.*.private_ip, count.index)}"
    user    = "core"
    timeout = "15m"
    
    bastion_host = "${format("bastion.%s.%s.", var.cluster_name, var.dns_zone)}"
    private_key = "${file(var.instance_pem)}"
  }

  provisioner "file" {
    content     = "${module.bootkube.kubeconfig}"
    destination = "$HOME/kubeconfig"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_ca_cert}"
    destination = "$HOME/etcd-client-ca.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_client_cert}"
    destination = "$HOME/etcd-client.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_client_key}"
    destination = "$HOME/etcd-client.key"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_server_cert}"
    destination = "$HOME/etcd-server.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_server_key}"
    destination = "$HOME/etcd-server.key"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_peer_cert}"
    destination = "$HOME/etcd-peer.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_peer_key}"
    destination = "$HOME/etcd-peer.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/ssl/etcd/etcd",
      "sudo mv etcd-client* /etc/ssl/etcd/",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/server-ca.crt",
      "sudo mv etcd-server.crt /etc/ssl/etcd/etcd/server.crt",
      "sudo mv etcd-server.key /etc/ssl/etcd/etcd/server.key",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/peer-ca.crt",
      "sudo mv etcd-peer.crt /etc/ssl/etcd/etcd/peer.crt",
      "sudo mv etcd-peer.key /etc/ssl/etcd/etcd/peer.key",
      "sudo chown -R etcd:etcd /etc/ssl/etcd",
      "sudo chmod -R 500 /etc/ssl/etcd",
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
    ]
  }
}

# Secure copy bootkube assets to ONE controller and start bootkube to perform
# one-time self-hosted cluster bootstrapping.
resource "null_resource" "bootkube-start" {
  depends_on = ["module.bootkube", "null_resource.copy-secrets", "aws_route53_record.apiserver"]

  connection {
    type    = "ssh"
    host    = "${aws_instance.controllers.0.private_ip}"
    user    = "core"
    timeout = "15m"
    bastion_host = "${format("bastion.%s.%s.", var.cluster_name, var.dns_zone)}"
    private_key = "${file(var.instance_pem)}"
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
