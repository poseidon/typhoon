# DNS record for the apiserver load balancer
resource "azurerm_dns_a_record" "apiserver" {
  resource_group_name = var.dns_zone_group

  # DNS Zone name where record should be created
  zone_name = var.dns_zone

  # DNS record
  name = var.cluster_name
  ttl  = 300

  # IPv4 address of apiserver load balancer
  records = [azurerm_public_ip.apiserver-ipv4.ip_address]
}

# Static IPv4 address for the apiserver frontend
resource "azurerm_public_ip" "apiserver-ipv4" {
  resource_group_name = azurerm_resource_group.cluster.name

  name              = "${var.cluster_name}-apiserver-ipv4"
  location          = var.region
  sku               = "Standard"
  allocation_method = "Static"
}

# Static IPv4 address for the ingress frontend
resource "azurerm_public_ip" "ingress-ipv4" {
  resource_group_name = azurerm_resource_group.cluster.name

  name              = "${var.cluster_name}-ingress-ipv4"
  location          = var.region
  sku               = "Standard"
  allocation_method = "Static"
}

# Network Load Balancer for apiservers and ingress
resource "azurerm_lb" "cluster" {
  resource_group_name = azurerm_resource_group.cluster.name

  name     = var.cluster_name
  location = var.region
  sku      = "Standard"

  frontend_ip_configuration {
    name                 = "apiserver"
    public_ip_address_id = azurerm_public_ip.apiserver-ipv4.id
  }

  frontend_ip_configuration {
    name                 = "ingress"
    public_ip_address_id = azurerm_public_ip.ingress-ipv4.id
  }
}

resource "azurerm_lb_rule" "apiserver" {
  resource_group_name = azurerm_resource_group.cluster.name

  name                           = "apiserver"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "apiserver"

  protocol                = "Tcp"
  frontend_port           = 6443
  backend_port            = 6443
  backend_address_pool_id = azurerm_lb_backend_address_pool.controller.id
  probe_id                = azurerm_lb_probe.apiserver.id
}

resource "azurerm_lb_rule" "ingress-http" {
  resource_group_name = azurerm_resource_group.cluster.name

  name                           = "ingress-http"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "ingress"
  disable_outbound_snat          = true

  protocol                = "Tcp"
  frontend_port           = 80
  backend_port            = 80
  backend_address_pool_id = azurerm_lb_backend_address_pool.worker.id
  probe_id                = azurerm_lb_probe.ingress.id
}

resource "azurerm_lb_rule" "ingress-https" {
  resource_group_name = azurerm_resource_group.cluster.name

  name                           = "ingress-https"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "ingress"
  disable_outbound_snat          = true

  protocol                = "Tcp"
  frontend_port           = 443
  backend_port            = 443
  backend_address_pool_id = azurerm_lb_backend_address_pool.worker.id
  probe_id                = azurerm_lb_probe.ingress.id
}

# Worker outbound TCP/UDP SNAT
resource "azurerm_lb_outbound_rule" "worker-outbound" {
  resource_group_name = azurerm_resource_group.cluster.name

  name            = "worker"
  loadbalancer_id = azurerm_lb.cluster.id
  frontend_ip_configuration {
    name = "ingress"
  }

  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.worker.id
}

# Address pool of controllers
resource "azurerm_lb_backend_address_pool" "controller" {
  name            = "controller"
  loadbalancer_id = azurerm_lb.cluster.id
}

# Address pool of workers
resource "azurerm_lb_backend_address_pool" "worker" {
  name            = "worker"
  loadbalancer_id = azurerm_lb.cluster.id
}

# Health checks / probes

# TCP health check for apiserver
resource "azurerm_lb_probe" "apiserver" {
  resource_group_name = azurerm_resource_group.cluster.name

  name            = "apiserver"
  loadbalancer_id = azurerm_lb.cluster.id
  protocol        = "Tcp"
  port            = 6443

  # unhealthy threshold
  number_of_probes = 3

  interval_in_seconds = 5
}

# HTTP health check for ingress
resource "azurerm_lb_probe" "ingress" {
  resource_group_name = azurerm_resource_group.cluster.name

  name            = "ingress"
  loadbalancer_id = azurerm_lb.cluster.id
  protocol        = "Http"
  port            = 10254
  request_path    = "/healthz"

  # unhealthy threshold
  number_of_probes = 3

  interval_in_seconds = 5
}

