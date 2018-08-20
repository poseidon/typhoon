# Organize cluster into a resource group
resource "azurerm_resource_group" "cluster" {
  name     = "${var.cluster_name}"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "network" {
  resource_group_name = "${azurerm_resource_group.cluster.name}"

  name          = "${var.cluster_name}"
  location      = "${azurerm_resource_group.cluster.location}"
  address_space = ["${var.host_cidr}"]
}

# Subnets - separate subnets for controller and workers because Azure
# network security groups are based on IPv4 CIDR rather than instance
# tags like GCP or security group membership like AWS

resource "azurerm_subnet" "controller" {
  resource_group_name = "${azurerm_resource_group.cluster.name}"

  name                 = "controller"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "${cidrsubnet(var.host_cidr, 1, 0)}"
}

resource "azurerm_subnet" "worker" {
  resource_group_name = "${azurerm_resource_group.cluster.name}"

  name                 = "worker"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "${cidrsubnet(var.host_cidr, 1, 1)}"
}
