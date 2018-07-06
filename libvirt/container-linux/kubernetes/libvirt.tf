// Some basic libvirt building blocks:
// - the network
// - the base QCOW volume 

resource "libvirt_network" "net" {
  name = "${var.cluster_name}"

  mode   = "nat"
  domain = "${var.machine_domain}"
  addresses = ["${var.node_ip_pool}"]

  dns_forwarder {
    address = "${var.dns_server}"
  }
}

resource "libvirt_volume" "base" {
  name   = "${var.cluster_name}-base"
  source = "${var.base_image_path}"
}

# Set up the cluster domain name
# we have to use the 
resource "null_resource" "k8s_domain_name" {
  count = "${var.libvirt_create_k8s_domain_name}"

  provisioner "local-exec" {
    command = "virsh -c qemu:///system net-update ${var.cluster_name} add dns-host \"<host ip='${libvirt_domain.controller.0.network_interface.0.addresses.0}'><hostname>${var.k8s_domain_name}</hostname></host>\" --live --config"
  }

  depends_on = ["libvirt_network.net"]
}
