output "kubeconfig-admin" {
  value = "${module.bootkube.kubeconfig-admin}"
}

# Outputs for Kubernetes Ingress

output "ingress_dns_name" {
  value       = "${aws_lb.nlb.dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

output "ingress_zone_id" {
  value       = "${aws_lb.nlb.zone_id}"
  description = "Route53 zone id of the network load balancer DNS name that can be used in Route53 alias records"
}

# Outputs for worker pools

output "vpc_id" {
  value       = "${local.manage_vpc ? join("", aws_vpc.network.*.id) : var.vpc_id}"
  description = "ID of the VPC for creating worker instances"
}

output "subnet_ids" {
  # work around for https://github.com/hashicorp/terraform/issues/18259
  value       = ["${split(":", length(var.public_subnets) > 0 ? join(":", var.public_subnets) : join(":", aws_subnet.public.*.id))}"]
  description = "List of subnet IDs for creating worker instances"
}

output "worker_security_groups" {
  value       = ["${aws_security_group.worker.id}"]
  description = "List of worker security group IDs"
}

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig-kubelet}"
}

output "server" {
  value = "${module.bootkube.server}"
}

output "ca_cert" {
  value = "${module.bootkube.ca_cert}"
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
