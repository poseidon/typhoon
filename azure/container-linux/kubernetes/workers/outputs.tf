output "principal_id" {
  value = azurerm_virtual_machine_scale_set.workers.identity[0].principal_id
}
