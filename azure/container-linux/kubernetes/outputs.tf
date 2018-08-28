# Outputs for Kubernetes Ingress

output "ingress_static_ipv4" {
  value       = "${azurerm_public_ip.ingress-ipv4.ip_address}"
  description = "IPv4 address of the load balancer for distributing traffic to Ingress controllers"
}

# Outputs for worker pools

output "region" {
  value = "${azurerm_resource_group.cluster.location}"
}

output "resource_group_name" {
  value = "${azurerm_resource_group.cluster.name}"
}

output "subnet_id" {
  value = "${azurerm_subnet.worker.id}"
}

output "security_group_id" {
  value = "${azurerm_network_security_group.worker.id}"
}

output "backend_address_pool_id" {
  value = "${azurerm_lb_backend_address_pool.worker.id}"
}

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}
