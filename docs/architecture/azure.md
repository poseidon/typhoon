# Azure

## Load Balancing

![Load Balancing](/img/typhoon-azure-load-balancing.png)

### kube-apiserver

A load balancer distributes IPv4 TCP/6443 traffic across a backend address pool of controllers with a healthy `kube-apiserver`. Clusters with multiple controllers use an availability set with 2 fault domains to tolerate hardware failures within Azure.

### HTTP/HTTPS Ingress

An Azure Load Balancer distributes IPv4/IPv6 TCP/80 and TCP/443 traffic across backend address pools of workers with a healthy Ingress controller.

The load balancer addresses are output as `ingress_static_ipv4` and `ingress_static_ipv6` for use in DNS A and AAAA records. See [Ingress on Azure](/addons/ingress/#azure).

### TCP/UDP Services

Load balance TCP/UDP applications by adding rules to the Azure LB (output). A rule may map different ports (e.g. 3333 external, 30333 internal).

```tf
# Forward traffic to the worker backend address pool
resource "azurerm_lb_rule" "some-app-tcp" {
  name                           = "some-app-tcp"
  resource_group_name            = module.ramius.resource_group_name
  loadbalancer_id                = module.ramius.loadbalancer_id
  frontend_ip_configuration_name = "ingress-ipv4"

  protocol                 = "Tcp"
  frontend_port            = 3333
  backend_port             = 30333
  backend_address_pool_ids = module.ramius.backend_address_pool_ids.ipv4
  probe_id                 = azurerm_lb_probe.some-app.id
}

# Health check some-app
resource "azurerm_lb_probe" "some-app" {
  name                = "some-app"
  resource_group_name = module.ramius.resource_group_name
  loadbalancer_id     = module.ramius.loadbalancer_id
  protocol            = "Tcp"
  port                = 30333
}
```

## Firewalls

Add firewall rules to the worker security group.

```tf
resource "azurerm_network_security_rule" "some-app" {
  name                         = "some-app"
  resource_group_name          = module.ramius.resource_group_name
  network_security_group_name  = module.ramius.worker_security_group_name
  priority                     = "3001"
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "30333"
  source_address_prefix        = "*"
  destination_address_prefixes = module.ramius.worker_address_prefixes.ipv4
}
```

## IPv6

Azure does not provide public IPv6 addresses at the standard SKU.

| IPv6 Feature            | Supported |
|-------------------------|-----------|
| Node IPv6 address       | Yes       |
| Node Outbound IPv6      | Yes       |
| Kubernetes Ingress IPv6 | Yes       |
