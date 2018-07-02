variable "name" {
  type        = "string"
  description = "Unique name for the worker pool"
}

# AWS

variable "vpc_id" {
  type        = "string"
  description = "Must be set to `vpc_id` output by cluster"
}

variable "subnet_ids" {
  type        = "list"
  description = "Must be set to `subnet_ids` output by cluster"
}

variable "security_groups" {
  type        = "list"
  description = "Must be set to `worker_security_groups` output by cluster"
}

# instances

variable "count" {
  type        = "string"
  default     = "1"
  description = "Number of instances"
}

variable "instance_type" {
  type        = "string"
  default     = "t2.small"
  description = "EC2 instance type"
}

variable "os_image" {
  type        = "string"
  default     = "coreos-stable"
  description = "AMI channel for a Container Linux derivative (coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, flatcar-alpha)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "Size of the EBS volume in GB"
}

variable "disk_type" {
  type        = "string"
  default     = "gp2"
  description = "Type of the EBS volume (e.g. standard, gp2, io1)"
}

variable "spot_price" {
  type        = "string"
  default     = ""
  description = "Spot price in USD for autoscaling group spot instances. Leave as default empty string for autoscaling group to use on-demand instances. Note, switching in-place from spot to on-demand is not possible: https://github.com/terraform-providers/terraform-provider-aws/issues/4320"
}

variable "clc_snippets" {
  type        = "list"
  description = "Container Linux Config snippets"
  default     = []
}

# configuration

variable "kubeconfig" {
  type        = "string"
  description = "Must be set to `kubeconfig` output by cluster"
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'core'"
}

variable "service_cidr" {
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}
