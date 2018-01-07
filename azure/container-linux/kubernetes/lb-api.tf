# kube-apiserver Azure Load Balancer DNS Record
resource "azurerm_dns_a_record" "apiserver" {
  name                = "${var.cluster_name}"
  zone_name           = "${var.dns_zone}"
  resource_group_name = "${var.dns_zone_rg}"
  ttl                 = 60
  records             = ["${azurerm_public_ip.apiserver.ip_address}"]
}

# kube-apiserver Public IP
resource "azurerm_public_ip" "apiserver" {
  name                         = "${var.cluster_name}-pip-api"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resource_group.name}"
  public_ip_address_allocation = "static"

  tags {
    name = "${var.cluster_name}"
  }
}

# Controller Azure Load Balancer
resource "azurerm_lb" "apiserver" {
  name                = "${var.cluster_name}-apiserver"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  frontend_ip_configuration {
    name                 = "apiserver"
    public_ip_address_id = "${azurerm_public_ip.apiserver.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "apiserver" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.apiserver.id}"
  name                = "apiserver"
}

resource "azurerm_lb_rule" "apiserver" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.apiserver.id}"
  name                = "apiserver"
  protocol            = "TCP"
  frontend_port       = 443
  backend_port        = 443

  # TODO: Parameterize
  frontend_ip_configuration_name = "apiserver"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.apiserver.id}"
  probe_id                       = "${azurerm_lb_probe.apiserver.id}"
}

resource "azurerm_lb_probe" "apiserver" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.apiserver.id}"
  name                = "apiserver-probe"
  port                = 443
  number_of_probes    = 4
  interval_in_seconds = 6
}
