output "kubeconfig-admin" {
  value = module.bootstrap.kubeconfig-admin
}

# Outputs for Kubernetes Ingress

output "ingress_static_ipv4" {
  value       = azurerm_public_ip.ingress-ipv4.ip_address
  description = "IPv4 address of the load balancer for distributing traffic to Ingress controllers"
}

# Outputs for worker pools

output "region" {
  value = azurerm_resource_group.cluster.location
}

output "resource_group_name" {
  value = azurerm_resource_group.cluster.name
}

output "resource_group_id" {
  value = azurerm_resource_group.cluster.id
}

output "subnet_id" {
  value = azurerm_subnet.worker.id
}

output "security_group_id" {
  value = azurerm_network_security_group.worker.id
}

output "kubeconfig" {
  value = module.bootstrap.kubeconfig-kubelet
}

# Outputs for custom firewalling

output "worker_security_group_name" {
  value = azurerm_network_security_group.worker.name
}

output "worker_address_prefix" {
  description = "Worker network subnet CIDR address (for source/destination)"
  value       = azurerm_subnet.worker.address_prefix
}

# Outputs for custom load balancing

output "loadbalancer_id" {
  description = "ID of the cluster load balancer"
  value       = azurerm_lb.cluster.id
}

output "backend_address_pool_id" {
  description = "ID of the worker backend address pool"
  value       = azurerm_lb_backend_address_pool.worker.id
}
