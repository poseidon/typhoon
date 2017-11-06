output "etcd_fqdns" {
  value = ["${null_resource.repeat.*.triggers.domain}"]
}

output "ipv4_public" {
  value = ["${google_compute_instance.controllers.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}
