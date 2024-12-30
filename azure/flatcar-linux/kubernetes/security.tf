# Controller security group

resource "azurerm_network_security_group" "controller" {
  name                = "${var.cluster_name}-controller"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = azurerm_resource_group.cluster.location
}

resource "azurerm_network_security_rule" "controller-icmp" {
  for_each = local.controller_subnets

  name                         = "allow-icmp-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 1995 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Icmp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

resource "azurerm_network_security_rule" "controller-ssh" {
  for_each = local.controller_subnets

  name                         = "allow-ssh-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2000 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "22"
  source_address_prefix        = "*"
  destination_address_prefixes = local.controller_subnets[each.key]
}

resource "azurerm_network_security_rule" "controller-etcd" {
  for_each = local.controller_subnets

  name                         = "allow-etcd-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2005 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "2379-2380"
  source_address_prefixes      = local.controller_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

# Allow Prometheus to scrape etcd metrics
resource "azurerm_network_security_rule" "controller-etcd-metrics" {
  for_each = local.controller_subnets

  name                         = "allow-etcd-metrics-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2010 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "2381"
  source_address_prefixes      = local.worker_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

# Allow Prometheus to scrape kube-proxy metrics
resource "azurerm_network_security_rule" "controller-kube-proxy" {
  for_each = local.controller_subnets

  name                         = "allow-kube-proxy-metrics-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2012 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "10249"
  source_address_prefixes      = local.worker_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

# Allow Prometheus to scrape kube-scheduler and kube-controller-manager metrics
resource "azurerm_network_security_rule" "controller-kube-metrics" {
  for_each = local.controller_subnets

  name                         = "allow-kube-metrics-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2014 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "10257-10259"
  source_address_prefixes      = local.worker_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

resource "azurerm_network_security_rule" "controller-apiserver" {
  for_each = local.controller_subnets

  name                         = "allow-apiserver-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2016 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "6443"
  source_address_prefix        = "*"
  destination_address_prefixes = local.controller_subnets[each.key]
}

resource "azurerm_network_security_rule" "controller-cilium-health" {
  for_each = var.networking == "cilium" ? local.controller_subnets : {}

  name                         = "allow-cilium-health-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2018 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "4240"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

resource "azurerm_network_security_rule" "controller-cilium-metrics" {
  for_each = var.networking == "cilium" ? local.controller_subnets : {}

  name                         = "allow-cilium-metrics-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2035 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "9962-9965"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

resource "azurerm_network_security_rule" "controller-vxlan" {
  for_each = local.controller_subnets

  name                         = "allow-vxlan-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2020 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Udp"
  source_port_range            = "*"
  destination_port_range       = "8472"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

# Allow Prometheus to scrape node-exporter daemonset
resource "azurerm_network_security_rule" "controller-node-exporter" {
  for_each = local.controller_subnets

  name                         = "allow-node-exporter-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.controller.name
  priority                     = 2025 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "9100"
  source_address_prefixes      = local.worker_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

# Allow apiserver to access kubelet's for exec, log, port-forward
resource "azurerm_network_security_rule" "controller-kubelet" {
  for_each = local.controller_subnets

  name                        = "allow-kubelet-${each.key}"
  resource_group_name         = azurerm_resource_group.cluster.name
  network_security_group_name = azurerm_network_security_group.controller.name
  priority                    = 2030 + (each.key == "ipv4" ? 0 : 1)
  access                      = "Allow"
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  # allow Prometheus to scrape kubelet metrics too
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.controller_subnets[each.key]
}

# Override Azure AllowVNetInBound and AllowAzureLoadBalancerInBound
# https://docs.microsoft.com/en-us/azure/virtual-network/security-overview#default-security-rules

resource "azurerm_network_security_rule" "controller-allow-loadblancer" {
  resource_group_name = azurerm_resource_group.cluster.name

  name                        = "allow-loadbalancer"
  network_security_group_name = azurerm_network_security_group.controller.name
  priority                    = "3000"
  access                      = "Allow"
  direction                   = "Inbound"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "controller-deny-all" {
  resource_group_name = azurerm_resource_group.cluster.name

  name                        = "deny-all"
  network_security_group_name = azurerm_network_security_group.controller.name
  priority                    = "3005"
  access                      = "Deny"
  direction                   = "Inbound"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Worker security group

resource "azurerm_network_security_group" "worker" {
  name                = "${var.cluster_name}-worker"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = azurerm_resource_group.cluster.location
}

resource "azurerm_network_security_rule" "worker-icmp" {
  for_each = local.worker_subnets

  name                         = "allow-icmp-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 1995 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Icmp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

resource "azurerm_network_security_rule" "worker-ssh" {
  for_each = local.worker_subnets

  name                         = "allow-ssh-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2000 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "22"
  source_address_prefixes      = local.controller_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

resource "azurerm_network_security_rule" "worker-http" {
  for_each = local.worker_subnets

  name                         = "allow-http-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2005 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "80"
  source_address_prefix        = "*"
  destination_address_prefixes = local.worker_subnets[each.key]
}

resource "azurerm_network_security_rule" "worker-https" {
  for_each = local.worker_subnets

  name                         = "allow-https-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2010 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefix        = "*"
  destination_address_prefixes = local.worker_subnets[each.key]
}

resource "azurerm_network_security_rule" "worker-cilium-health" {
  for_each = var.networking == "cilium" ? local.worker_subnets : {}

  name                         = "allow-cilium-health-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2012 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "4240"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

resource "azurerm_network_security_rule" "worker-cilium-metrics" {
  for_each = var.networking == "cilium" ? local.worker_subnets : {}

  name                         = "allow-cilium-metrics-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2014 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "9962-9965"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

resource "azurerm_network_security_rule" "worker-vxlan" {
  for_each = local.worker_subnets

  name                         = "allow-vxlan-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2016 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Udp"
  source_port_range            = "*"
  destination_port_range       = "8472"
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

# Allow Prometheus to scrape node-exporter daemonset
resource "azurerm_network_security_rule" "worker-node-exporter" {
  for_each = local.worker_subnets

  name                         = "allow-node-exporter-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2020 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "9100"
  source_address_prefixes      = local.worker_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

# Allow Prometheus to scrape kube-proxy
resource "azurerm_network_security_rule" "worker-kube-proxy" {
  for_each = local.worker_subnets

  name                         = "allow-kube-proxy-${each.key}"
  resource_group_name          = azurerm_resource_group.cluster.name
  network_security_group_name  = azurerm_network_security_group.worker.name
  priority                     = 2024 + (each.key == "ipv4" ? 0 : 1)
  access                       = "Allow"
  direction                    = "Inbound"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "10249"
  source_address_prefixes      = local.worker_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

# Allow apiserver to access kubelet's for exec, log, port-forward
resource "azurerm_network_security_rule" "worker-kubelet" {
  for_each = local.worker_subnets

  name                        = "allow-kubelet-${each.key}"
  resource_group_name         = azurerm_resource_group.cluster.name
  network_security_group_name = azurerm_network_security_group.worker.name
  priority                    = 2026 + (each.key == "ipv4" ? 0 : 1)
  access                      = "Allow"
  direction                   = "Inbound"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  # allow Prometheus to scrape kubelet metrics too
  source_address_prefixes      = local.cluster_subnets[each.key]
  destination_address_prefixes = local.worker_subnets[each.key]
}

# Override Azure AllowVNetInBound and AllowAzureLoadBalancerInBound
# https://docs.microsoft.com/en-us/azure/virtual-network/security-overview#default-security-rules

resource "azurerm_network_security_rule" "worker-allow-loadblancer" {
  resource_group_name = azurerm_resource_group.cluster.name

  name                        = "allow-loadbalancer"
  network_security_group_name = azurerm_network_security_group.worker.name
  priority                    = "3000"
  access                      = "Allow"
  direction                   = "Inbound"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "worker-deny-all" {
  resource_group_name = azurerm_resource_group.cluster.name

  name                        = "deny-all"
  network_security_group_name = azurerm_network_security_group.worker.name
  priority                    = "3005"
  access                      = "Deny"
  direction                   = "Inbound"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

