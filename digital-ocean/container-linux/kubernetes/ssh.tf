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
    content     = module.bootstrap.etcd_ca_cert
    destination = "$HOME/etcd-client-ca.crt"
  }

  provisioner "file" {
    content     = module.bootstrap.etcd_client_cert
    destination = "$HOME/etcd-client.crt"
  }

  provisioner "file" {
    content     = module.bootstrap.etcd_client_key
    destination = "$HOME/etcd-client.key"
  }

  provisioner "file" {
    content     = module.bootstrap.etcd_server_cert
    destination = "$HOME/etcd-server.crt"
  }

  provisioner "file" {
    content     = module.bootstrap.etcd_server_key
    destination = "$HOME/etcd-server.key"
  }

  provisioner "file" {
    content     = module.bootstrap.etcd_peer_cert
    destination = "$HOME/etcd-peer.crt"
  }

  provisioner "file" {
    content     = module.bootstrap.etcd_peer_key
    destination = "$HOME/etcd-peer.key"
  }

  provisioner "file" {
    source      = var.asset_dir
    destination = "$HOME/assets"
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
      "sudo mv $HOME/assets /opt/bootstrap/assets",
      "sudo mkdir -p /etc/kubernetes/manifests",
      "sudo mkdir -p /etc/kubernetes/bootstrap-secrets",
      "sudo mv $HOME/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo cp -r /opt/bootstrap/assets/tls/* /etc/kubernetes/bootstrap-secrets/",
      "sudo cp /opt/bootstrap/assets/auth/kubeconfig /etc/kubernetes/bootstrap-secrets/",
      "sudo cp -r /opt/bootstrap/assets/static-manifests/* /etc/kubernetes/manifests/",
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

