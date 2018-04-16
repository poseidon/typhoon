output "ingress_static_ip" {
  value = "${google_compute_address.ingress-ip.address}"
}
