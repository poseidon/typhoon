# kube-apiserver Network Load Balancer DNS Record
# all service checks are ensured by consul servers
# even if it doesnt follow consul philosophy
data "template_file" "controller_consul_services" {
  count = "${var.controller_count}"

  template = <<TPL
{
  "services": [
    {
      "id": "etcd_$${node_id}",
      "name": "etcd",
      "address": "$${ipv4_addr}",
      "port": 2379,
      "tags": [ "$${node_name}" ],
      "checks": [
        {
           "id": "etcd_client_$${node_id}",
           "name": "etcd tcp on port 2379",
           "tcp": "$${ipv4_addr}:2379",
           "interval": "10s",
           "timeout": "1s"
        },
        {
           "id": "etcd_server_$${node_id}",
           "name": "etcd tcp on port 2380",
           "tcp": "$${ipv4_addr}:2380",
           "interval": "10s",
           "timeout": "1s"
        }
      ]
    },
    {
      "id": "apiserver_$${node_id}",
      "name": "apiserver",
      "tags": [ "$${node_name}", "urlprefix-:443","proto=tcp" ],
      "address": "$${ipv4_addr}",
      "port": 443,
      "checks": [
        {
          "id": "apiserver_$${node_id}",
          "name": "Kube controller https api",
          "tcp": "$${ipv4_addr}:443",
          "interval": "10s",
          "timeout": "1s"
        }
      ]
    }
  ]
}
TPL

  vars = {
    node_name = "${count.index}"
    node_id   = "${element(openstack_compute_instance_v2.controllers.*.id, count.index)}"
    ipv4_addr = "${element(flatten(openstack_networking_port_v2.port_controllers.*.all_fixed_ips), count.index)}"
  }
}

resource "null_resource" "register_services" {
  count = "${var.controller_count}"

  triggers {
    etcd_port_id  = "${element(openstack_networking_port_v2.port_controllers.*.id, count.index)}"
    consul_server = "${element(module.consul_servers.instance_ids, count.index)}"
  }

  connection {
    host                = "${element(module.consul_servers.ipv4_addrs, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.admin_network.bastion_public_ip}"
    bastion_user        = "${var.ssh_bastion_user}"
    bastion_private_key = "${var.ssh_bastion_private_key}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.controller_consul_services.*.rendered, count.index)}"
    destination = "/tmp/services_controller${count.index}.json"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -d /opt/consul/config ]; then sudo mkdir -p /opt/consul/config; fi",
      "sudo cp /tmp/services_controller${count.index}.json /opt/consul/config",
      "if systemctl is-active consul; then sudo systemctl reload consul; fi"
    ]
  }
}
