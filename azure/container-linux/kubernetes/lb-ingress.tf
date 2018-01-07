# Ingress Azure Load Balancer DNS Record
resource "azurerm_dns_a_record" "ingress" {
  name                = "${var.cluster_name}-in"
  zone_name           = "${var.dns_zone}"
  resource_group_name = "${var.dns_zone_rg}"
  ttl                 = 60
  records             = ["${azurerm_public_ip.ingress.ip_address}"]
}

# Ingress Public IP
resource "azurerm_public_ip" "ingress" {
  name                         = "${var.cluster_name}-pip-ingress"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resource_group.name}"
  public_ip_address_allocation = "static"

  tags {
    name = "${var.cluster_name}"
  }
}

# Controller Azure Load Balancer
resource "azurerm_lb" "ingress" {
  name                = "${var.cluster_name}-ingress"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  frontend_ip_configuration {
    name                 = "ingress"
    public_ip_address_id = "${azurerm_public_ip.ingress.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "ingress" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.ingress.id}"
  name                = "ingress"
}

resource "azurerm_lb_rule" "ingress_http" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.ingress.id}"
  name                = "ingress-http"
  protocol            = "TCP"
  frontend_port       = 80
  backend_port        = 80

  # TODO: Parameterize
  frontend_ip_configuration_name = "ingress"
}

resource "azurerm_lb_rule" "ingress_https" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.ingress.id}"
  name                = "ingress-https"
  protocol            = "TCP"
  frontend_port       = 443
  backend_port        = 443

  # TODO: Parameterize
  frontend_ip_configuration_name = "ingress"
}

resource "azurerm_lb_probe" "ingress" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.ingress.id}"
  name                = "ingress-probe"
  protocol            = "Http"
  port                = 10254
  request_path        = "/healthz"
  number_of_probes    = 4
  interval_in_seconds = 6
}
