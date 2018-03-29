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

variable "os_channel" {
  type        = "string"
  default     = "stable"
  description = "Container Linux AMI channel (stable, beta, alpha)"
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
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by kube-dns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}
