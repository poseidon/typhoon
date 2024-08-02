locals {
  # Container Linux derivative
  # flatcar-stable -> Flatcar Linux Stable
  channel      = split("-", var.os_image)[1]
  offer_suffix = var.controller_arch == "arm64" ? "corevm" : "free"
  urn          = var.controller_arch == "arm64" ? local.channel : "${local.channel}-gen2"

  # Typhoon ssh_authorized_key supports RSA or a newer formats (e.g. ed25519).
  # However, Azure requires an older RSA key to pass validations. To use a
  # newer key format, pass a dummy RSA key as the azure_authorized_key and
  # delete the associated private key so it's never used.
  azure_authorized_key = var.azure_authorized_key == "" ? var.ssh_authorized_key : var.azure_authorized_key
}

# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "azurerm_dns_a_record" "etcds" {
  count = var.controller_count

  # DNS Zone name where record should be created
  zone_name           = var.dns_zone
  resource_group_name = var.dns_zone_group
  # DNS record
  name = format("%s-etcd%d", var.cluster_name, count.index)
  ttl  = 300
  # private IPv4 address for etcd
  records = [azurerm_network_interface.controllers[count.index].private_ip_address]
}

# Controller availability set to spread controllers
resource "azurerm_availability_set" "controllers" {
  name                         = "${var.cluster_name}-controllers"
  resource_group_name          = azurerm_resource_group.cluster.name
  location                     = var.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 4
  managed                      = true
}

# Controller instances
resource "azurerm_linux_virtual_machine" "controllers" {
  count = var.controller_count

  name                = "${var.cluster_name}-controller-${count.index}"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = var.location
  availability_set_id = azurerm_availability_set.controllers.id
  size                = var.controller_type

  # storage
  os_disk {
    name                 = "${var.cluster_name}-controller-${count.index}"
    storage_account_type = var.controller_disk_type
    disk_size_gb         = var.controller_disk_size
    caching              = "None"
  }

  # Flatcar Container Linux
  source_image_reference {
    publisher = "kinvolk"
    offer     = "flatcar-container-linux-${local.offer_suffix}"
    sku       = local.urn
    version   = "latest"
  }

  dynamic "plan" {
    for_each = var.controller_arch == "arm64" ? [] : [1]
    content {
      publisher = "kinvolk"
      product   = "flatcar-container-linux-${local.offer_suffix}"
      name      = local.urn
    }
  }

  # network
  network_interface_ids = [
    azurerm_network_interface.controllers[count.index].id
  ]

  # boot
  custom_data = base64encode(data.ct_config.controllers[count.index].rendered)
  boot_diagnostics {
    # defaults to a managed storage account
  }

  # Azure requires an RSA admin_ssh_key
  admin_username = "core"
  admin_ssh_key {
    username   = "core"
    public_key = local.azure_authorized_key
  }

  lifecycle {
    ignore_changes = [
      os_disk,
      custom_data,
    ]
  }
}

# Controller node public IPv4 addresses
resource "azurerm_public_ip" "controllers-ipv4" {
  count = var.controller_count

  name                = "${var.cluster_name}-controller-${count.index}-ipv4"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = azurerm_resource_group.cluster.location
  ip_version          = "IPv4"
  sku                 = "Standard"
  allocation_method   = "Static"
}

# Controller node public IPv6 addresses
resource "azurerm_public_ip" "controllers-ipv6" {
  count = var.controller_count

  name                = "${var.cluster_name}-controller-${count.index}-ipv6"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = azurerm_resource_group.cluster.location
  ip_version          = "IPv6"
  sku                 = "Standard"
  allocation_method   = "Static"
}

# Controllers' network interfaces
resource "azurerm_network_interface" "controllers" {
  count = var.controller_count

  name                = "${var.cluster_name}-controller-${count.index}"
  resource_group_name = azurerm_resource_group.cluster.name
  location            = azurerm_resource_group.cluster.location

  ip_configuration {
    name                          = "ipv4"
    primary                       = true
    subnet_id                     = azurerm_subnet.controller.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.controllers-ipv4[count.index].id
  }
  ip_configuration {
    name                          = "ipv6"
    subnet_id                     = azurerm_subnet.controller.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv6"
    public_ip_address_id          = azurerm_public_ip.controllers-ipv6[count.index].id
  }
}

# Associate controller network interface with controller security group
resource "azurerm_network_interface_security_group_association" "controllers" {
  count = var.controller_count

  network_interface_id      = azurerm_network_interface.controllers[count.index].id
  network_security_group_id = azurerm_network_security_group.controller.id
}

# Associate controller network interface with controller backend address pools
resource "azurerm_network_interface_backend_address_pool_association" "controllers-ipv4" {
  count = var.controller_count

  network_interface_id    = azurerm_network_interface.controllers[count.index].id
  ip_configuration_name   = "ipv4"
  backend_address_pool_id = azurerm_lb_backend_address_pool.controller-ipv4.id
}

resource "azurerm_network_interface_backend_address_pool_association" "controllers-ipv6" {
  count = var.controller_count

  network_interface_id    = azurerm_network_interface.controllers[count.index].id
  ip_configuration_name   = "ipv6"
  backend_address_pool_id = azurerm_lb_backend_address_pool.controller-ipv6.id
}

# Flatcar Linux controllers
data "ct_config" "controllers" {
  count = var.controller_count
  content = templatefile("${path.module}/butane/controller.yaml", {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = join(",", [
      for i in range(var.controller_count) : "etcd${i}=https://${var.cluster_name}-etcd${i}.${var.dns_zone}:2380"
    ])
    kubeconfig             = indent(10, module.bootstrap.kubeconfig-kubelet)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
  })
  strict   = true
  snippets = var.controller_snippets
}
