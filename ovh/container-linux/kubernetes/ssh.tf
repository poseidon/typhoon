# Secure copy etcd TLS assets and kubeconfig to controllers. Activates kubelet.service
resource "null_resource" "copy-secrets" {
  count = "${var.controller_count}"

  triggers {
    hostid = "${element(openstack_compute_instance_v2.controllers.*.id, count.index)}"
  }

  connection {
    type                = "ssh"
    host                = "${element(openstack_compute_instance_v2.controllers.*.access_ip_v4, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.admin_network.bastion_public_ip}"
    bastion_user        = "${var.ssh_bastion_user}"
    bastion_private_key = "${var.ssh_bastion_private_key}"
    timeout             = "15m"
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
      "sudo cp -Rf /home/core/kubeconfig /etc/kubernetes/",
      "sudo rm -Rf /home/core/kubeconfig",
    ]
  }
}

# Secure copy bootkube assets to ONE controller and start bootkube to perform
# one-time self-hosted cluster bootstrapping.
resource "null_resource" "bootkube-start" {
  depends_on = ["module.bootkube", "null_resource.copy-secrets", "ovh_domain_zone_record.apiserver"]

  triggers {
    hostid = "${element(openstack_compute_instance_v2.controllers.*.id,0)}"
  }

  connection {
    type                = "ssh"
    host                = "${openstack_compute_instance_v2.controllers.0.access_ip_v4}"
    user                = "${var.ssh_user}"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.admin_network.bastion_public_ip}"
    bastion_user        = "${var.ssh_bastion_user}"
    bastion_private_key = "${var.ssh_bastion_private_key}"
    timeout             = "15m"
  }

  provisioner "file" {
    source      = "${var.asset_dir}"
    destination = "$HOME/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp -Rf /home/core/assets /opt/bootkube/",
      "sudo rm -Rf /home/core/assets",
      "sudo systemctl restart bootkube",
    ]
  }
}
