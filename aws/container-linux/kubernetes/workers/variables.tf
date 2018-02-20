variable "name" {
  type        = "string"
  description = "Unique name instance group"
}

variable "vpc_id" {
  type        = "string"
  description = "ID of the VPC for creating instances"
}

variable "subnet_ids" {
  type        = "list"
  description = "List of subnet IDs for creating instances"
}

variable "security_groups" {
  type        = "list"
  description = "List of security group IDs"
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
  description = "Size of the disk in GB"
}

# configuration

variable "kubeconfig" {
  type        = "string"
  description = "Generated Kubelet kubeconfig"
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

variable "clc_snippets" {
  type        = "list"
  description = "Container Linux Config snippets"
  default     = []
}
