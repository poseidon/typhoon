locals {
  # format assets for distribution
  assets_bundle = [
    # header with the unpack location
    for key, value in module.bootstrap.assets_dist :
    format("##### %s\n%s", key, value)
  ]
}

# Secure copy assets to controllers.
resource "null_resource" "copy-controller-secrets" {
  count = var.controller_count

  depends_on = [
    module.bootstrap,
  ]

  connection {
    type    = "ssh"
    host    = local.controllers_ipv4_public[count.index]
    user    = "core"
    timeout = "15m"
  }

  provisioner "file" {
    content     = join("\n", local.assets_bundle)
    destination = "/home/core/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/bootstrap/layout",
    ]
  }
}

# Connect to a controller to perform one-time cluster bootstrap.
resource "null_resource" "bootstrap" {
  depends_on = [
    null_resource.copy-controller-secrets,
    module.workers,
    google_dns_record_set.apiserver,
  ]

  connection {
    type    = "ssh"
    host    = local.controllers_ipv4_public[0]
    user    = "core"
    timeout = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}

