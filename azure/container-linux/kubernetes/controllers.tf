# TODO: Add Scale Sets implementation once support exists: https://github.com/kubernetes/kubernetes/issues/43287

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
  resource_group_name = "${azurerm_resource_group.rg.name}"
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
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.controller.*.id[count.index]}"]
  vm_size               = "${var.controller_type}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${var.os_channel}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.cluster_name}-controller-${count.index}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
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
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                                    = "controllerIPConfig"
    subnet_id                               = "${azurerm_subnet.controller.id}"
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
  resource_group_name          = "${azurerm_resource_group.rg.name}"
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
resource "azurerm_network_security_group" "controller" {
  name                = "${var.cluster_name}-controller"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    name = "${var.cluster_name}-controller"
  }
}

resource "azurerm_network_security_rule" "controller-egress" {
  name                        = "controller-egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-ssh" {
  name                        = "controller-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-apiserver" {
  name                        = "controller-apiserver"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-etcd" {
  name                        = "controller-etcd"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "2379-2380"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-flannel" {
  name                        = "controller-flannel"
  priority                    = 250
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-flannel-self" {
  name                        = "controller-flannel-self"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-node-exporter" {
  name                        = "controller-node-exporter"
  priority                    = 350
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-kubelet" {
  name                        = "controller-kubelet"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-kubelet-read" {
  name                        = "controller-kubelet-read"
  priority                    = 450
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-kubelet-read-self" {
  name                        = "controller-kubelet-read-self"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-bgp" {
  name                        = "controller-bgp"
  priority                    = 550
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}

resource "azurerm_network_security_rule" "controller-bgp-self" {
  name                        = "controller-bgp-self"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.controller_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.controller.name}"
}
