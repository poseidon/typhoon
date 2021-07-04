variable "name" {
  type        = string
  description = "Unique name for the worker pool"
}

# AWS

variable "vpc_id" {
  type        = string
  description = "Must be set to `vpc_id` output by cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Must be set to `subnet_ids` output by cluster"
}

variable "security_groups" {
  type        = list(string)
  description = "Must be set to `worker_security_groups` output by cluster"
}

# instances

variable "worker_count" {
  type        = number
  description = "Number of instances"
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "os_stream" {
  type        = string
  description = "Fedora CoreOS image stream for instances (e.g. stable, testing, next)"
  default     = "stable"

  validation {
    condition     = contains(["stable", "testing", "next"], var.os_stream)
    error_message = "The os_stream must be stable, testing, or next."
  }
}

variable "disk_size" {
  type        = number
  description = "Size of the EBS volume in GB"
  default     = 30
}

variable "disk_type" {
  type        = string
  description = "Type of the EBS volume (e.g. standard, gp2, gp3, io1)"
  default     = "gp3"
}

variable "disk_iops" {
  type        = number
  description = "IOPS of the EBS volume (required for io1)"
  default     = 0
}

variable "spot_price" {
  type        = number
  description = "Spot price in USD for worker instances or 0 to use on-demand instances"
  default     = 0
}

variable "target_groups" {
  type        = list(string)
  description = "Additional target group ARNs to which instances should be added"
  default     = []
}

variable "snippets" {
  type        = list(string)
  description = "Fedora CoreOS Config snippets"
  default     = []
}

# configuration

variable "kubeconfig" {
  type        = string
  description = "Must be set to `kubeconfig` output by cluster"
}

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  type        = string
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  default     = "cluster.local"
}

variable "node_labels" {
  type        = list(string)
  description = "List of initial node labels"
  default     = []
}

variable "node_taints" {
  type        = list(string)
  description = "List of initial node taints"
  default     = []
}

# unofficial, undocumented, unsupported

variable "arch" {
  type        = string
  description = "Container architecture (amd64 or arm64)"
  default     = "amd64"

  validation {
    condition     = var.arch == "amd64" || var.arch == "arm64"
    error_message = "The arch must be amd64 or arm64."
  }
}
