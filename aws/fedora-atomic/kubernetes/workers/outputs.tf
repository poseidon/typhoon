output "ingress_dns_name" {
  value       = "${aws_lb.ingress.dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}
