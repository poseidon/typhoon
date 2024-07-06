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
  name                = "${var.cluster_name}-apiserver-ipv4"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = var.region
  sku                 = "Standard"
  allocation_method   = "Static"
}

# Static IPv4 address for the ingress frontend
resource "azurerm_public_ip" "ingress-ipv4" {
  name                = "${var.cluster_name}-ingress-ipv4"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = var.region
  ip_version          = "IPv4"
  sku                 = "Standard"
  allocation_method   = "Static"
}

# Static IPv6 address for the ingress frontend
resource "azurerm_public_ip" "ingress-ipv6" {
  name                = "${var.cluster_name}-ingress-ipv6"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = var.region
  ip_version          = "IPv6"
  sku                 = "Standard"
  allocation_method   = "Static"
}

# Network Load Balancer for apiservers and ingress
resource "azurerm_lb" "cluster" {
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.cluster.name
  location            = var.region
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "apiserver"
    public_ip_address_id = azurerm_public_ip.apiserver-ipv4.id
  }

  frontend_ip_configuration {
    name                 = "ingress-ipv4"
    public_ip_address_id = azurerm_public_ip.ingress-ipv4.id
  }

  frontend_ip_configuration {
    name                 = "ingress-ipv6"
    public_ip_address_id = azurerm_public_ip.ingress-ipv6.id
  }
}

resource "azurerm_lb_rule" "apiserver" {
  name                           = "apiserver"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "apiserver"
  disable_outbound_snat          = true

  protocol                 = "Tcp"
  frontend_port            = 6443
  backend_port             = 6443
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.controller.id]
  probe_id                 = azurerm_lb_probe.apiserver.id
}

resource "azurerm_lb_rule" "ingress-http-ipv4" {
  name                           = "ingress-http-ipv4"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "ingress-ipv4"
  disable_outbound_snat          = true

  protocol                 = "Tcp"
  frontend_port            = 80
  backend_port             = 80
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.worker-ipv4.id]
  probe_id                 = azurerm_lb_probe.ingress.id
}

resource "azurerm_lb_rule" "ingress-https-ipv4" {
  name                           = "ingress-https-ipv4"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "ingress-ipv4"
  disable_outbound_snat          = true

  protocol                 = "Tcp"
  frontend_port            = 443
  backend_port             = 443
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.worker-ipv4.id]
  probe_id                 = azurerm_lb_probe.ingress.id
}

resource "azurerm_lb_rule" "ingress-http-ipv6" {
  name                           = "ingress-http-ipv6"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "ingress-ipv6"
  disable_outbound_snat          = true

  protocol                 = "Tcp"
  frontend_port            = 80
  backend_port             = 80
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.worker-ipv6.id]
  probe_id                 = azurerm_lb_probe.ingress.id
}

resource "azurerm_lb_rule" "ingress-https-ipv6" {
  name                           = "ingress-https-ipv6"
  loadbalancer_id                = azurerm_lb.cluster.id
  frontend_ip_configuration_name = "ingress-ipv6"
  disable_outbound_snat          = true

  protocol                 = "Tcp"
  frontend_port            = 443
  backend_port             = 443
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.worker-ipv6.id]
  probe_id                 = azurerm_lb_probe.ingress.id
}

# Backend Address Pools

# Address pool of controllers
resource "azurerm_lb_backend_address_pool" "controller" {
  name            = "controller"
  loadbalancer_id = azurerm_lb.cluster.id
}

# Address pool of workers
resource "azurerm_lb_backend_address_pool" "worker-ipv4" {
  name            = "worker-ipv4"
  loadbalancer_id = azurerm_lb.cluster.id
}

resource "azurerm_lb_backend_address_pool" "worker-ipv6" {
  name            = "worker-ipv6"
  loadbalancer_id = azurerm_lb.cluster.id
}

# Health checks / probes

# TCP health check for apiserver
resource "azurerm_lb_probe" "apiserver" {
  name            = "apiserver"
  loadbalancer_id = azurerm_lb.cluster.id
  protocol        = "Tcp"
  port            = 6443
  # unhealthy threshold
  number_of_probes    = 3
  interval_in_seconds = 5
}

# HTTP health check for ingress
resource "azurerm_lb_probe" "ingress" {
  name            = "ingress"
  loadbalancer_id = azurerm_lb.cluster.id
  protocol        = "Http"
  port            = 10254
  request_path    = "/healthz"
  # unhealthy threshold
  number_of_probes    = 3
  interval_in_seconds = 5
}

# Outbound SNAT

resource "azurerm_lb_outbound_rule" "outbound-ipv4" {
  name                    = "outbound-ipv4"
  protocol                = "All"
  loadbalancer_id         = azurerm_lb.cluster.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.worker-ipv4.id
  frontend_ip_configuration {
    name = "ingress-ipv4"
  }
}

resource "azurerm_lb_outbound_rule" "outbound-ipv6" {
  name                    = "outbound-ipv6"
  protocol                = "All"
  loadbalancer_id         = azurerm_lb.cluster.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.worker-ipv6.id
  frontend_ip_configuration {
    name = "ingress-ipv6"
  }
}
