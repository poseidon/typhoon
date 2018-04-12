# Deprecated
output "controllers_ipv4_public" {
  value = ["${google_compute_instance.controllers.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "ingress_static_ip" {
  value = "${module.workers.ingress_static_ip}"
}

output "network_self_link" {
  value = "${google_compute_network.network.self_link}"
}

# Outputs for worker pools

output "network_name" {
  value = "${google_compute_network.network.name}"
}

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}
