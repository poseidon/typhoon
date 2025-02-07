variable "cluster_name" {
  type        = string
  description = "Unique cluster name (prepended to dns_zone)"
}

# AWS

variable "dns_zone" {
  type        = string
  description = "AWS Route53 DNS Zone (e.g. aws.example.com)"
}

variable "dns_zone_id" {
  type        = string
  description = "AWS Route53 DNS Zone ID (e.g. Z3PAABBCFAKEC0)"
}

# instances

variable "os_stream" {
  type        = string
  description = "Fedora CoreOS image stream for instances (e.g. stable, testing, next)"
  default     = "stable"

  validation {
    condition     = contains(["stable", "testing", "next"], var.os_stream)
    error_message = "The os_stream must be stable, testing, or next."
  }
}

variable "controller_count" {
  type        = number
  description = "Number of controllers (i.e. masters)"
  default     = 1
}

variable "controller_type" {
  type        = string
  description = "EC2 instance type for controllers"
  default     = "t3.small"
}

variable "controller_disk_size" {
  type        = number
  description = "Size of the EBS volume in GB"
  default     = 30
}

variable "controller_disk_type" {
  type        = string
  description = "Type of the EBS volume (e.g. standard, gp2, gp3, io1)"
  default     = "gp3"
}

variable "controller_disk_iops" {
  type        = number
  description = "IOPS of the EBS volume (e.g. 3000)"
  default     = 3000
}

variable "controller_cpu_credits" {
  type        = string
  description = "CPU credits mode (if using a burstable instance type)"
  default     = null
}

variable "worker_count" {
  type        = number
  description = "Number of workers"
  default     = 1
}

variable "worker_type" {
  type        = string
  description = "EC2 instance type for workers"
  default     = "t3.small"
}

variable "worker_disk_size" {
  type        = number
  description = "Size of the EBS volume in GB"
  default     = 30
}

variable "worker_disk_type" {
  type        = string
  description = "Type of the EBS volume (e.g. standard, gp2, gp3, io1)"
  default     = "gp3"
}

variable "worker_disk_iops" {
  type        = number
  description = "IOPS of the EBS volume (e.g. 3000)"
  default     = 3000
}

variable "worker_cpu_credits" {
  type        = string
  description = "CPU credits mode (if using a burstable instance type)"
  default     = null
}

variable "worker_price" {
  type        = number
  description = "Spot price in USD for worker instances or 0 to use on-demand instances"
  default     = 0
}

variable "worker_target_groups" {
  type        = list(string)
  description = "Additional target group ARNs to which worker instances should be added"
  default     = []
}

variable "controller_snippets" {
  type        = list(string)
  description = "Controller Butane snippets"
  default     = []
}

variable "worker_snippets" {
  type        = list(string)
  description = "Worker Butane snippets"
  default     = []
}

# configuration

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel or cilium)"
  default     = "cilium"
}

variable "host_cidr" {
  type        = string
  description = "CIDR IPv4 range to assign to EC2 nodes"
  default     = "10.0.0.0/16"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR IPv4 range to assign Kubernetes pods"
  default     = "10.20.0.0/14"
}

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
}

variable "worker_node_labels" {
  type        = list(string)
  description = "List of initial worker node labels"
  default     = []
}

# advanced

variable "controller_arch" {
  type        = string
  description = "Controller node(s) architecture (amd64 or arm64)"
  default     = "amd64"
  validation {
    condition     = contains(["amd64", "arm64"], var.controller_arch)
    error_message = "The controller_arch must be amd64 or arm64."
  }
}

variable "worker_arch" {
  type        = string
  description = "Worker node(s) architecture (amd64 or arm64)"
  default     = "amd64"
  validation {
    condition     = contains(["amd64", "arm64"], var.worker_arch)
    error_message = "The worker_arch must be amd64 or arm64."
  }
}

variable "daemonset_tolerations" {
  type        = list(string)
  description = "List of additional taint keys kube-system DaemonSets should tolerate (e.g. ['custom-role', 'gpu-role'])"
  default     = []
}

variable "components" {
  description = "Configure pre-installed cluster components"
  # Component configs are passed through to terraform-render-bootstrap,
  # which handles type enforcement and defines defaults
  # https://github.com/poseidon/terraform-render-bootstrap/blob/main/variables.tf#L95
  type = object({
    enable     = optional(bool)
    coredns    = optional(map(any))
    kube_proxy = optional(map(any))
    flannel    = optional(map(any))
    cilium     = optional(map(any))
  })
  default = null
}

variable "service_account_issuer" {
  type        = string
  description = "kube-apiserver service account token issuer (used as an identifier in 'iss' claims)"
  default     = "https://kubernetes.default.svc.cluster.local"
}
