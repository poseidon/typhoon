output "controllers_ipv4_public" {
  value = ["${module.controllers.ipv4_public}"]
}

output "controllers_ipv4_private" {
  value = ["${module.controllers.ipv4_private}"]
}

output "ingress_static_ip" {
  value = "${module.workers.ingress_static_ip}"
}
