# Azure

## Load Balancing

![Load Balancing](/img/typhoon-azure-load-balancing.png)

### kube-apiserver

A load balancer distributes IPv4 TCP/6443 traffic across a backend address pool of controllers with a healthy `kube-apiserver`. Clusters with multiple controllers use an availability set with 2 fault domains to tolerate hardware failures within Azure.

### HTTP/HTTPS Ingress

A load balancer distributes IPv4 TCP/80 and TCP/443 traffic across a backend address pool of workers with a healthy Ingress controller.

The Azure LB IPv4 address is output as `ingress_static_ipv4` for use in DNS A records. See [Ingress on Azure](/addons/ingress/#azure).

### TCP/UDP Services

Load balance TCP/UDP applications by adding rules to the Azure LB (output). A rule may map different ports (e.g. 3333 external, 30333 internal).

```tf
# Forward traffic to the worker backend address pool
resource "azurerm_lb_rule" "some-app-tcp" {
  resource_group_name = module.ramius.resource_group_name

  name                           = "some-app-tcp"
  loadbalancer_id                = module.ramius.loadbalancer_id
  frontend_ip_configuration_name = "ingress"

  protocol                = "Tcp"
  frontend_port           = 3333
  backend_port            = 30333
  backend_address_pool_id = module.ramius.backend_address_pool_id
  probe_id                = azurerm_lb_probe.some-app.id
}

# Health check some-app
resource "azurerm_lb_probe" "some-app" {
  resource_group_name = module.ramius.resource_group_name

  name            = "some-app"
  loadbalancer_id = module.ramius.loadbalancer_id
  protocol        = "Tcp"
  port            = 30333
}
```

## Firewalls

Add firewall rules to the worker security group.

```tf
resource "azurerm_network_security_rule" "some-app" {
  resource_group_name = "${module.ramius.resource_group_name}"

  name                        = "some-app"
  network_security_group_name = module.ramius.worker_security_group_name
  priority                    = "3001"
  access                      = "Allow"
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "30333"
  source_address_prefix       = "*"
  destination_address_prefix  = module.ramius.worker_address_prefix
}
```

## IPv6

Azure does not provide public IPv6 addresses at the standard SKU.

| IPv6 Feature            | Supported |
|-------------------------|-----------|
| Node IPv6 address       | No        |
| Node Outbound IPv6      | No        |
| Kubernetes Ingress IPv6 | No        |
