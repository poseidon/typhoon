# TODO: Add support for AZs (once supported)

# Network VPC, gateway, and routes

resource "azurerm_virtual_network" "network" {
  name                = "${var.cluster_name}-vnet"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  address_space       = ["${var.host_cidr}"]
  location            = "${var.location}"

  tags = "${map("Name", "${var.cluster_name}")}"
}

# TODO: Assess need for routes & route tables

# Subnets (one per availability zone)

# TODO: Assess need for public and private subnets
resource "azurerm_subnet" "public" {
  name                 = "${var.cluster_name}-public"
  resource_group_name  = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"

  # TODO: Parameterize
  address_prefix = "10.0.1.0/24"

  # TODO: network_security_group_id
  # TODO: route_table_id
}
