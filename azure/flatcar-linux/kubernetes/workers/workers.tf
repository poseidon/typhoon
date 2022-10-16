locals {
  # flatcar-stable -> Flatcar Linux Stable
  channel      = split("-", var.os_image)[1]
  offer_suffix = var.arch == "arm64" ? "corevm" : "free"
  urn          = var.arch == "arm64" ? local.channel : "${local.channel}-gen2"
}

# Workers scale set
resource "azurerm_linux_virtual_machine_scale_set" "workers" {
  resource_group_name = var.resource_group_name

  name      = "${var.name}-worker"
  location  = var.region
  sku       = var.vm_type
  instances = var.worker_count
  # instance name prefix for instances in the set
  computer_name_prefix   = "${var.name}-worker"
  single_placement_group = false
  custom_data            = base64encode(data.ct_config.worker.rendered)

  # storage
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  # Flatcar Container Linux
  source_image_reference {
    publisher = "kinvolk"
    offer     = "flatcar-container-linux-${local.offer_suffix}"
    sku       = local.urn
    version   = "latest"
  }

  dynamic "plan" {
    for_each = var.arch == "arm64" ? [] : [1]
    content {
      publisher = "kinvolk"
      product   = "flatcar-container-linux-${local.offer_suffix}"
      name      = local.urn
    }
  }

  # Azure requires setting admin_ssh_key, though Ignition custom_data handles it too
  admin_username = "core"
  admin_ssh_key {
    username   = "core"
    public_key = var.ssh_authorized_key
  }

  # network
  network_interface {
    name                      = "nic0"
    primary                   = true
    network_security_group_id = var.security_group_id

    ip_configuration {
      name      = "ip0"
      primary   = true
      subnet_id = var.subnet_id

      # backend address pool to which the NIC should be added
      load_balancer_backend_address_pool_ids = [var.backend_address_pool_id]
    }
  }

  # lifecycle
  upgrade_mode = "Manual"
  # eviction policy may only be set when priority is Spot
  priority        = var.priority
  eviction_policy = var.priority == "Spot" ? "Delete" : null
}

# Scale up or down to maintain desired number, tolerating deallocations.
resource "azurerm_monitor_autoscale_setting" "workers" {
  resource_group_name = var.resource_group_name

  name     = "${var.name}-maintain-desired"
  location = var.region

  # autoscale
  enabled            = true
  target_resource_id = azurerm_linux_virtual_machine_scale_set.workers.id

  profile {
    name = "default"

    capacity {
      minimum = var.worker_count
      default = var.worker_count
      maximum = var.worker_count
    }
  }
}

# Flatcar Linux worker
data "ct_config" "worker" {
  content = templatefile("${path.module}/butane/worker.yaml", {
    kubeconfig             = indent(10, var.kubeconfig)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
    node_labels            = join(",", var.node_labels)
    node_taints            = join(",", var.node_taints)
  })
  strict   = true
  snippets = var.snippets
}
