# Outputs for Kubernetes Ingress

output "ingress_dns_name" {
  value       = "${aws_lb.nlb.dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

# Outputs for worker pools

output "vpc_id" {
  value       = "${aws_vpc.network.id}"
  description = "ID of the VPC for creating worker instances"
}

output "subnet_ids" {
  value       = ["${aws_subnet.public.*.id}"]
  description = "List of subnet IDs for creating worker instances"
}

output "worker_security_groups" {
  value       = ["${aws_security_group.worker.id}"]
  description = "List of worker security group IDs"
}

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}

# Outputs for custom load balancing

output "worker_target_group_http" {
  description = "ARN of a target group of workers for HTTP traffic"
  value       = "${module.workers.target_group_http}"
}

output "worker_target_group_https" {
  description = "ARN of a target group of workers for HTTPS traffic"
  value       = "${module.workers.target_group_https}"
}
