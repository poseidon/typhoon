locals {
  backend_address_pool_ids = {
    ipv4 = [azurerm_lb_backend_address_pool.worker-ipv4.id]
    ipv6 = [azurerm_lb_backend_address_pool.worker-ipv6.id]
  }
}
