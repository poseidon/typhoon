locals {
  # flatcar-stable -> Flatcar Linux Stable
  channel      = split("-", var.os_image)[1]
  offer_suffix = var.arch == "arm64" ? "corevm" : "free"
  urn          = var.arch == "arm64" ? local.channel : "${local.channel}-gen2"

  azure_authorized_key = var.azure_authorized_key == "" ? var.ssh_authorized_key : var.azure_authorized_key
}

# Workers scale set
resource "azurerm_orchestrated_virtual_machine_scale_set" "workers" {
  name                        = "${var.name}-worker"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  platform_fault_domain_count = 1
  sku_name                    = var.vm_type
  instances                   = var.worker_count

  # storage
  encryption_at_host_enabled = true
  os_disk {
    storage_account_type = var.disk_type
    disk_size_gb         = var.disk_size
    caching              = "ReadOnly"
    # Optionally, use the ephemeral disk of the instance type (support varies)
    dynamic "diff_disk_settings" {
      for_each = var.ephemeral_disk ? [1] : []
      content {
        option    = "Local"
        placement = "ResourceDisk"
      }
    }
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

  # network
  network_interface {
    name                      = "nic0"
    primary                   = true
    network_security_group_id = var.security_group_id

    ip_configuration {
      name      = "ipv4"
      version   = "IPv4"
      primary   = true
      subnet_id = var.subnet_id
      # backend address pool to which the NIC should be added
      load_balancer_backend_address_pool_ids = var.backend_address_pool_ids.ipv4
    }
    ip_configuration {
      name      = "ipv6"
      version   = "IPv6"
      subnet_id = var.subnet_id
      # backend address pool to which the NIC should be added
      load_balancer_backend_address_pool_ids = var.backend_address_pool_ids.ipv6
    }
  }

  # boot
  user_data_base64 = base64encode(data.ct_config.worker.rendered)
  boot_diagnostics {
    # defaults to a managed storage account
  }

  # Azure requires an RSA admin_ssh_key
  os_profile {
    linux_configuration {
      admin_username = "core"
      admin_ssh_key {
        username   = "core"
        public_key = local.azure_authorized_key
      }
      computer_name_prefix = "${var.name}-worker"
    }
  }

  # Roll out VMSS changes to instances gradually
  upgrade_mode = "Rolling"
  rolling_upgrade_policy {
    max_batch_instance_percent = 20
    pause_time_between_batches = "PT2M"

    maximum_surge_instances_enabled = true
    # Upgrade unhealthy instances first
    prioritize_unhealthy_instances_enabled = true

    # Safety gate to stop bad rollouts
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 25
  }

  # Azure instance repair replaces instances that fail probes from the
  # ApplicationHealthExtension
  automatic_instance_repair {
    enabled      = true
    grace_period = "PT15M"
    action       = "Replace"
  }

  extension {
    name                 = "ApplicationHealthExtension"
    publisher            = "Microsoft.ManagedServices"
    type                 = "ApplicationHealthLinux"
    type_handler_version = "1.0"
    settings = jsonencode({
      protocol    = "http"
      port        = 10256
      requestPath = "/healthz"
    })
  }


  # lifecycle
  # eviction policy may only be set when priority is Spot
  priority        = var.priority
  eviction_policy = var.priority == "Spot" ? "Delete" : null
  termination_notification {
    enabled = true
  }
}

# Flatcar Linux worker
data "ct_config" "worker" {
  content = templatefile("${path.module}/butane/worker.yaml", {
    kubeconfig             = indent(10, var.kubeconfig)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    node_labels            = join(",", var.node_labels)
    node_taints            = join(",", var.node_taints)
  })
  strict   = true
  snippets = var.snippets
}

# Scale up or down to maintain desired number, tolerating deallocations.
resource "azurerm_monitor_autoscale_setting" "workers" {
  name                = "${var.name}-maintain-desired"
  resource_group_name = var.resource_group_name
  location            = var.location
  # autoscale
  enabled            = true
  target_resource_id = azurerm_orchestrated_virtual_machine_scale_set.workers.id
  profile {
    name = "default"
    capacity {
      minimum = var.worker_count
      default = var.worker_count
      maximum = var.worker_count
    }
  }
}
