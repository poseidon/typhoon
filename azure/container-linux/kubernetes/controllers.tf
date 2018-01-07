# TODO: Add support for Scale Sets

# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "azurerm_dns_a_record" "etcds" {
  count = "${var.controller_count}"

  name                = "${format("%s-etcd%d", var.cluster_name, count.index)}"
  zone_name           = "${var.dns_zone}"
  resource_group_name = "${var.dns_zone_rg}"
  ttl                 = 60
  records             = ["${element(azurerm_network_interface.controller.*.private_ip_address, count.index)}"]
}

# Controllers Availability Set
resource "azurerm_availability_set" "controllers" {
  name                = "${var.cluster_name}-controllers"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  managed             = true

  tags {
    name = "${var.cluster_name}-controller"
  }
}

# Controller instances
resource "azurerm_virtual_machine" "controller" {
  count = "${var.controller_count}"

  name                  = "${var.cluster_name}-controller-${count.index}"
  location              = "${var.location}"
  availability_set_id   = "${azurerm_availability_set.controllers.id}"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.controller.*.id[count.index]}"]
  vm_size               = "${var.controller_type}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${var.os_channel}"

    # TODO: Parameterize
    version = "latest"
  }

  storage_os_disk {
    name          = "${var.cluster_name}-controller-${count.index}-os"
    caching       = "ReadWrite"
    create_option = "FromImage"

    # TODO: Parameterize
    managed_disk_type = "Premium_LRS"
    os_type           = "linux"
    disk_size_gb      = "${var.disk_size}"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-controller-${count.index}"
    admin_username = "core"
    admin_password = ""
    custom_data    = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${var.ssh_authorized_key}"
    }
  }

  tags {
    name = "${var.cluster_name}"
  }
}

# Controller NIC
resource "azurerm_network_interface" "controller" {
  count = "${var.controller_count}"

  name                = "${var.cluster_name}-controller-${count.index}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  # TODO: network_security_group_id

  ip_configuration {
    name                                    = "controllerIPConfig"
    subnet_id                               = "${azurerm_subnet.public.id}"
    private_ip_address_allocation           = "dynamic"
    public_ip_address_id                    = "${element(azurerm_public_ip.controller.*.id, count.index)}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.apiserver.id}"]
  }
  tags {
    name = "${var.cluster_name}"
  }
}

# Controller Public IP
resource "azurerm_public_ip" "controller" {
  count = "${var.controller_count}"

  name                         = "${var.cluster_name}-pip-controller-${count.index}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resource_group.name}"
  public_ip_address_allocation = "static"

  tags {
    name = "${var.cluster_name}"
  }
}

# Controller Container Linux Config
data "template_file" "controller_config" {
  count = "${var.controller_count}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = "${join(",", formatlist("%s=https://%s:2380", null_resource.repeat.*.triggers.name, null_resource.repeat.*.triggers.domain))}"

    k8s_dns_service_ip      = "${cidrhost(var.service_cidr, 10)}"
    ssh_authorized_key      = "${var.ssh_authorized_key}"
    cluster_domain_suffix   = "${var.cluster_domain_suffix}"
    kubeconfig_ca_cert      = "${module.bootkube.ca_cert}"
    kubeconfig_kubelet_cert = "${module.bootkube.kubelet_cert}"
    kubeconfig_kubelet_key  = "${module.bootkube.kubelet_key}"
    kubeconfig_server       = "${module.bootkube.server}"
  }
}

# Horrible hack to generate a Terraform list of a desired length without dependencies.
# Ideal ${repeat("etcd", 3) -> ["etcd", "etcd", "etcd"]}
resource null_resource "repeat" {
  count = "${var.controller_count}"

  triggers {
    name   = "etcd${count.index}"
    domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
  }
}

data "ct_config" "controller_ign" {
  count        = "${var.controller_count}"
  content      = "${element(data.template_file.controller_config.*.rendered, count.index)}"
  pretty_print = false
}

# Security Group (instance firewall)


# TODO: Add security rules
/*
resource "aws_security_group" "controller" {
  name        = "${var.cluster_name}-controller"
  description = "${var.cluster_name} controller security group"

  vpc_id = "${aws_vpc.network.id}"

  tags = "${map("Name", "${var.cluster_name}-controller")}"
}

resource "aws_security_group_rule" "controller-icmp" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "icmp"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controller-ssh" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controller-apiserver" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controller-etcd" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "controller-flannel" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8472
  to_port                  = 8472
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "controller-flannel-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "udp"
  from_port = 8472
  to_port   = 8472
  self      = true
}

resource "aws_security_group_rule" "controller-node-exporter" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9100
  to_port                  = 9100
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "controller-kubelet-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

resource "aws_security_group_rule" "controller-kubelet-read" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10255
  to_port                  = 10255
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "controller-kubelet-read-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255
  self      = true
}

resource "aws_security_group_rule" "controller-bgp" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 179
  to_port                  = 179
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "controller-bgp-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 179
  to_port   = 179
  self      = true
}

resource "aws_security_group_rule" "controller-ipip" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = 4
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "controller-ipip-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = 4
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "controller-ipip-legacy" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = 94
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "controller-ipip-legacy-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = 94
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "controller-egress" {
  security_group_id = "${aws_security_group.controller.id}"

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
*/
