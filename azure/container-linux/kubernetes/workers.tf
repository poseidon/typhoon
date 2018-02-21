# TODO: Add Scale Sets implementation once support exists: https://github.com/kubernetes/kubernetes/issues/43287

# Workers Availability Set
resource "azurerm_availability_set" "workers" {
  name                = "${var.cluster_name}-workers"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  managed             = true

  tags {
    name = "${var.cluster_name}-worker"
  }
}

# Worker VM
resource "azurerm_virtual_machine" "worker" {
  count = "${var.worker_count}"

  name                  = "${var.cluster_name}-worker-${count.index}"
  location              = "${var.location}"
  availability_set_id   = "${azurerm_availability_set.workers.id}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.worker.*.id, count.index)}"]
  vm_size               = "${var.worker_type}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${var.os_channel}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.cluster_name}-worker-${count.index}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    os_type           = "linux"
    disk_size_gb      = "${var.disk_size}"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-worker-${count.index}"
    admin_username = "core"
    admin_password = ""
    custom_data    = "${data.ct_config.worker_ign.rendered}"
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

# Worker NIC
resource "azurerm_network_interface" "worker" {
  count = "${var.worker_count}"

  name                = "${var.cluster_name}-worker-${count.index}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                                    = "workerIPConfig"
    subnet_id                               = "${azurerm_subnet.worker.id}"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.ingress.id}"]
  }

  tags {
    name = "${var.cluster_name}"
  }
}

# Worker Container Linux Config
data "template_file" "worker_config" {
  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars = {
    k8s_dns_service_ip      = "${cidrhost(var.service_cidr, 10)}"
    k8s_etcd_service_ip     = "${cidrhost(var.service_cidr, 15)}"
    ssh_authorized_key      = "${var.ssh_authorized_key}"
    cluster_domain_suffix   = "${var.cluster_domain_suffix}"
    kubeconfig_ca_cert      = "${module.bootkube.ca_cert}"
    kubeconfig_kubelet_cert = "${module.bootkube.kubelet_cert}"
    kubeconfig_kubelet_key  = "${module.bootkube.kubelet_key}"
    kubeconfig_server       = "${module.bootkube.server}"
  }
}

data "ct_config" "worker_ign" {
  content      = "${data.template_file.worker_config.rendered}"
  pretty_print = false
}

# Security Group (instance firewall)
resource "azurerm_network_security_group" "worker" {
  name                = "${var.cluster_name}-worker"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    name = "${var.cluster_name}-worker"
  }
}

resource "azurerm_network_security_rule" "worker-egress" {
  name                        = "worker-egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-ssh" {
  name                        = "worker-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-http" {
  name                        = "worker-http"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-https" {
  name                        = "worker-https"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-flannel" {
  name                        = "worker-flannel"
  priority                    = 250
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-flannel-self" {
  name                        = "worker-flannel-self"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "8472"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-node-exporter" {
  name                        = "worker-node-exporter"
  priority                    = 350
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet" {
  name                        = "worker-kubelet"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet-self" {
  name                        = "worker-kubelet-self"
  priority                    = 450
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet-read" {
  name                        = "worker-kubelet-read"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-kubelet-read-self" {
  name                        = "worker-kubelet-read-self"
  priority                    = 550
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "ingress-health-self" {
  name                        = "ingress-health-self"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "10254"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-bgp" {
  name                        = "worker-bgp"
  priority                    = 650
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.controller_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-bgp-self" {
  name                        = "worker-bgp-self"
  priority                    = 700
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "179"
  source_address_prefix       = "${var.worker_cidr}"
  destination_address_prefix  = "${var.worker_cidr}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}
