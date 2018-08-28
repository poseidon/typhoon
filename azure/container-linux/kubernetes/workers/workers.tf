locals {
  # Channel for a Container Linux derivative
  # coreos-stable -> Container Linux Stable
  channel = "${element(split("-", var.os_image), 1)}"
}

# Workers scale set
resource "azurerm_virtual_machine_scale_set" "workers" {
  resource_group_name = "${var.resource_group_name}"

  name                   = "${var.name}-workers"
  location               = "${var.region}"
  single_placement_group = false

  sku {
    name     = "${var.vm_type}"
    tier     = "standard"
    capacity = "${var.count}"
  }

  # boot
  storage_profile_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${local.channel}"
    version   = "latest"
  }

  # storage
  storage_profile_os_disk {
    create_option     = "FromImage"
    caching           = "ReadWrite"
    os_type           = "linux"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "${var.name}-worker-"
    admin_username       = "core"

    # Required by Azure, but password auth is disabled below
    admin_password = ""
    custom_data    = "${element(data.ct_config.worker-ignitions.*.rendered, count.index)}"
  }

  # Azure mandates setting an ssh_key, even though Ignition custom_data handles it too
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${var.ssh_authorized_key}"
    }
  }

  # network
  network_profile {
    name                      = "nic0"
    primary                   = true
    network_security_group_id = "${var.security_group_id}"

    ip_configuration {
      name      = "ip0"
      subnet_id = "${var.subnet_id}"

      # backend address pool to which the NIC should be added
      load_balancer_backend_address_pool_ids = ["${var.backend_address_pool_id}"]
    }
  }

  # lifecycle
  priority            = "${var.priority}"
  upgrade_policy_mode = "Manual"
}

# Scale up or down to maintain desired number, tolerating deallocations.
resource "azurerm_autoscale_setting" "workers" {
  resource_group_name = "${var.resource_group_name}"

  name     = "${var.name}-maintain-desired"
  location = "${var.region}"

  # autoscale
  enabled            = true
  target_resource_id = "${azurerm_virtual_machine_scale_set.workers.id}"

  profile {
    name = "default"

    capacity {
      minimum = "${var.count}"
      default = "${var.count}"
      maximum = "${var.count}"
    }
  }
}

# Worker Ignition configs
data "ct_config" "worker-ignitions" {
  content      = "${data.template_file.worker-configs.rendered}"
  pretty_print = false
  snippets     = ["${var.clc_snippets}"]
}

# Worker Container Linux configs
data "template_file" "worker-configs" {
  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars = {
    kubeconfig            = "${indent(10, var.kubeconfig)}"
    ssh_authorized_key    = "${var.ssh_authorized_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}
