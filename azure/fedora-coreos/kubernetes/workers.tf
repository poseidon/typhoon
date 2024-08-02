module "workers" {
  source = "./workers"
  name   = var.cluster_name

  # Azure
  resource_group_name      = azurerm_resource_group.cluster.name
  location                 = azurerm_resource_group.cluster.location
  subnet_id                = azurerm_subnet.worker.id
  security_group_id        = azurerm_network_security_group.worker.id
  backend_address_pool_ids = local.backend_address_pool_ids

  # instances
  os_image       = var.os_image
  worker_count   = var.worker_count
  vm_type        = var.worker_type
  disk_type      = var.worker_disk_type
  disk_size      = var.worker_disk_size
  ephemeral_disk = var.worker_ephemeral_disk
  priority       = var.worker_priority

  # configuration
  kubeconfig           = module.bootstrap.kubeconfig-kubelet
  ssh_authorized_key   = var.ssh_authorized_key
  azure_authorized_key = var.azure_authorized_key
  service_cidr         = var.service_cidr
  snippets             = var.worker_snippets
  node_labels          = var.worker_node_labels
}
