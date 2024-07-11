output "kubeconfig-admin" {
  value     = module.bootstrap.kubeconfig-admin
  sensitive = true
}

# Outputs for Kubernetes Ingress

output "ingress_static_ipv4" {
  value       = azurerm_public_ip.frontend-ipv4.ip_address
  description = "IPv4 address of the load balancer for distributing traffic to Ingress controllers"
}

output "ingress_static_ipv6" {
  value       = azurerm_public_ip.frontend-ipv6.ip_address
  description = "IPv6 address of the load balancer for distributing traffic to Ingress controllers"
}

# Outputs for worker pools

output "location" {
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
  value     = module.bootstrap.kubeconfig-kubelet
  sensitive = true
}

# Outputs for custom firewalling

output "controller_security_group_name" {
  description = "Network Security Group for controller nodes"
  value       = azurerm_network_security_group.controller.name
}

output "worker_security_group_name" {
  description = "Network Security Group for worker nodes"
  value       = azurerm_network_security_group.worker.name
}

output "controller_address_prefixes" {
  description = "Controller network subnet CIDR addresses (for source/destination)"
  value       = local.controller_subnets
}

output "worker_address_prefixes" {
  description = "Worker network subnet CIDR addresses (for source/destination)"
  value       = local.worker_subnets
}

# Outputs for custom load balancing

output "loadbalancer_id" {
  description = "ID of the cluster load balancer"
  value       = azurerm_lb.cluster.id
}

output "backend_address_pool_ids" {
  description = "IDs of the worker backend address pools"
  value = {
    ipv4 = [azurerm_lb_backend_address_pool.worker-ipv4.id]
    ipv6 = [azurerm_lb_backend_address_pool.worker-ipv6.id]
  }
}

# Outputs for debug

output "assets_dist" {
  value     = module.bootstrap.assets_dist
  sensitive = true
}

