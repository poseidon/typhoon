# TODO: Add support for AZs (once supported)

# Network VPC, gateway, and routes

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.cluster_name}-vnet"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  address_space       = ["${var.host_cidr}"]
  location            = "${var.location}"

  tags = "${map("Name", "${var.cluster_name}")}"
}

# TODO: Assess need for routes & route tables

# Subnets
resource "azurerm_subnet" "controller" {
  name                      = "${var.cluster_name}-controller"
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.controller_cidr}"
  network_security_group_id = "${azurerm_network_security_group.controller.id}"

  # TODO: route_table_id
}

resource "azurerm_subnet" "worker" {
  name                      = "${var.cluster_name}-worker"
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.worker_cidr}"
  network_security_group_id = "${azurerm_network_security_group.worker.id}"

  # TODO: route_table_id
}
