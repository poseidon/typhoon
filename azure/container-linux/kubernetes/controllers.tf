# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "azurerm_dns_a_record" "etcds" {
  count               = "${var.controller_count}"
  resource_group_name = "${var.dns_zone_group}"

  # DNS Zone name where record should be created
  zone_name = "${var.dns_zone}"

  # DNS record
  name = "${format("%s-etcd%d", var.cluster_name, count.index)}"
  ttl  = 300

  # private IPv4 address for etcd
  records = ["${element(azurerm_network_interface.controllers.*.private_ip_address, count.index)}"]
}

locals {
  # Channel for a Container Linux derivative
  # coreos-stable -> Container Linux Stable
  channel = "${element(split("-", var.os_image), 1)}"
}

# Controller availability set to spread controllers
resource "azurerm_availability_set" "controllers" {
  resource_group_name = "${azurerm_resource_group.cluster.name}"

  name                         = "${var.cluster_name}-controllers"
  location                     = "${var.region}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 4
  managed                      = true
}

# Controller instances
resource "azurerm_virtual_machine" "controllers" {
  count               = "${var.controller_count}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"

  name                = "${var.cluster_name}-controller-${count.index}"
  location            = "${var.region}"
  availability_set_id = "${azurerm_availability_set.controllers.id}"
  vm_size             = "${var.controller_type}"

  # boot
  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${local.channel}"
    version   = "latest"
  }

  # storage
  storage_os_disk {
    name              = "${var.cluster_name}-controller-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    disk_size_gb      = "${var.disk_size}"
    os_type           = "Linux"
    managed_disk_type = "Premium_LRS"
  }

  # network
  network_interface_ids = ["${element(azurerm_network_interface.controllers.*.id, count.index)}"]

  os_profile {
    computer_name  = "${var.cluster_name}-controller-${count.index}"
    admin_username = "core"
    custom_data    = "${element(data.ct_config.controller-ignitions.*.rendered, count.index)}"
  }

  # Azure mandates setting an ssh_key, even though Ignition custom_data handles it too
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${var.ssh_authorized_key}"
    }
  }

  # lifecycle
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  lifecycle {
    ignore_changes = [
      "storage_os_disk",
    ]
  }
}

# Controller NICs with public and private IPv4
resource "azurerm_network_interface" "controllers" {
  count               = "${var.controller_count}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"

  name                      = "${var.cluster_name}-controller-${count.index}"
  location                  = "${azurerm_resource_group.cluster.location}"
  network_security_group_id = "${azurerm_network_security_group.controller.id}"

  ip_configuration {
    name                          = "ip0"
    subnet_id                     = "${azurerm_subnet.controller.id}"
    private_ip_address_allocation = "dynamic"

    # public IPv4
    public_ip_address_id = "${element(azurerm_public_ip.controllers.*.id, count.index)}"

    # backend address pool to which the NIC should be added
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.controller.id}"]
  }
}

# Controller public IPv4 addresses
resource "azurerm_public_ip" "controllers" {
  count               = "${var.controller_count}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"

  name                         = "${var.cluster_name}-controller-${count.index}"
  location                     = "${azurerm_resource_group.cluster.location}"
  sku                          = "Standard"
  public_ip_address_allocation = "static"
}

# Controller Ignition configs
data "ct_config" "controller-ignitions" {
  count        = "${var.controller_count}"
  content      = "${element(data.template_file.controller-configs.*.rendered, count.index)}"
  pretty_print = false
  snippets     = ["${var.controller_clc_snippets}"]
}

# Controller Container Linux configs
data "template_file" "controller-configs" {
  count = "${var.controller_count}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = "${join(",", data.template_file.etcds.*.rendered)}"

    kubeconfig            = "${indent(10, module.bootkube.kubeconfig)}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "template_file" "etcds" {
  count    = "${var.controller_count}"
  template = "etcd$${index}=https://$${cluster_name}-etcd$${index}.$${dns_zone}:2380"

  vars {
    index        = "${count.index}"
    cluster_name = "${var.cluster_name}"
    dns_zone     = "${var.dns_zone}"
  }
}
