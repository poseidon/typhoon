output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}

output "kubeconfig-admin" {
  value = "${module.bootkube.user-kubeconfig}"
}
