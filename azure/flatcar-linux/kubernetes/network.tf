# Choose an IPv6 ULA subnet at random
# https://datatracker.ietf.org/doc/html/rfc4193
resource "random_id" "ula-netnum" {
  byte_length = 5 # 40 bits
}

locals {
  # fd00::/8 -> shift 40 -> 2^40 possible /48 subnets
  ula-range = cidrsubnet("fd00::/8", 40, random_id.ula-netnum.dec)
  network_cidr = {
    ipv4 = var.network_cidr.ipv4
    ipv6 = length(var.network_cidr.ipv6) > 0 ? var.network_cidr.ipv6 : [local.ula-range]
  }

  # Subdivide the virtual network into subnets
  # - controllers use netnum 0
  # - workers use netnum 1
  controller_subnets = {
    ipv4 = [for i, cidr in local.network_cidr.ipv4 : cidrsubnet(cidr, 1, 0)]
    ipv6 = [for i, cidr in local.network_cidr.ipv6 : cidrsubnet(cidr, 16, 0)]
  }
  worker_subnets = {
    ipv4 = [for i, cidr in local.network_cidr.ipv4 : cidrsubnet(cidr, 1, 1)]
    ipv6 = [for i, cidr in local.network_cidr.ipv6 : cidrsubnet(cidr, 16, 1)]
  }
  cluster_subnets = {
    ipv4 = concat(local.controller_subnets.ipv4, local.worker_subnets.ipv4)
    ipv6 = concat(local.controller_subnets.ipv6, local.worker_subnets.ipv6)
  }
}

# Organize cluster into a resource group
resource "azurerm_resource_group" "cluster" {
  name     = var.cluster_name
  location = var.location
}

resource "azurerm_virtual_network" "network" {
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.cluster.name
  location            = azurerm_resource_group.cluster.location
  address_space = concat(
    local.network_cidr.ipv4,
    local.network_cidr.ipv6
  )
}

# Subnets - separate subnets for controllers and workers because Azure
# network security groups are oriented around address prefixes rather
# than instance tags (GCP) or security group membership (AWS)

resource "azurerm_subnet" "controller" {
  name                 = "controller"
  resource_group_name  = azurerm_resource_group.cluster.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes = concat(
    local.controller_subnets.ipv4,
    local.controller_subnets.ipv6,
  )
  default_outbound_access_enabled = false
}

resource "azurerm_subnet_network_security_group_association" "controller" {
  subnet_id                 = azurerm_subnet.controller.id
  network_security_group_id = azurerm_network_security_group.controller.id
}

resource "azurerm_subnet" "worker" {
  name                 = "worker"
  resource_group_name  = azurerm_resource_group.cluster.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes = concat(
    local.worker_subnets.ipv4,
    local.worker_subnets.ipv6,
  )
  default_outbound_access_enabled = false
}

resource "azurerm_subnet_network_security_group_association" "worker" {
  subnet_id                 = azurerm_subnet.worker.id
  network_security_group_id = azurerm_network_security_group.worker.id
}
