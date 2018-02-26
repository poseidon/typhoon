output "controllers_ipv4_public" {
  value = ["${module.controllers.ipv4_public}"]
}

output "ingress_static_ip" {
  value = "${module.workers.ingress_static_ip}"
}

output "network_name" {
  value = "${google_compute_network.network.name}"
}

output "network_self_link" {
  value = "${google_compute_network.network.self_link}"
}

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}
