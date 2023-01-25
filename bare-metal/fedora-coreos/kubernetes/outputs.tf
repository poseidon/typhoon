output "kubeconfig-admin" {
  value     = module.bootstrap.kubeconfig-admin
  sensitive = true
}

# Outputs for workers

output "kubeconfig" {
  value     = module.bootstrap.kubeconfig-kubelet
  sensitive = true
}

# Outputs for debug

output "assets_dist" {
  value     = module.bootstrap.assets_dist
  sensitive = true
}

