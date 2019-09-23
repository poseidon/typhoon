# Secure copy assets to controllers. Activates kubelet.service
resource "null_resource" "copy-controller-secrets" {
  count = length(var.controller_names)

  # Without depends_on, remote-exec could start and wait for machines before
  # matchbox groups are written, causing a deadlock.
  depends_on = [
    matchbox_group.controller,
    matchbox_group.worker,
    module.bootstrap,
  ]

  connection {
    type    = "ssh"
    host    = var.controller_domains[count.index]
    user    = "core"
    timeout = "60m"
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
      "sudo mv $HOME/assets /opt/bootstrap/assets",
      "sudo mkdir -p /etc/kubernetes/manifests",
      "sudo mkdir -p /etc/kubernetes/bootstrap-secrets",
      "sudo mv $HOME/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo cp -r /opt/bootstrap/assets/tls/* /etc/kubernetes/bootstrap-secrets/",
      "sudo cp /opt/bootstrap/assets/auth/kubeconfig /etc/kubernetes/bootstrap-secrets/",
      "sudo cp -r /opt/bootstrap/assets/static-manifests/* /etc/kubernetes/manifests/"
    ]
  }
}

# Secure copy kubeconfig to all workers. Activates kubelet.service
resource "null_resource" "copy-worker-secrets" {
  count = length(var.worker_names)

  # Without depends_on, remote-exec could start and wait for machines before
  # matchbox groups are written, causing a deadlock.
  depends_on = [
    matchbox_group.controller,
    matchbox_group.worker,
  ]

  connection {
    type    = "ssh"
    host    = var.worker_domains[count.index]
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
    host    = var.controller_domains[0]
    user    = "core"
    timeout = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}


