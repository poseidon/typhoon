variable "cluster_name" {
  type        = string
  description = "Unique cluster name (prepended to dns_zone)"
}

# Google Cloud

variable "region" {
  type        = string
  description = "Google Cloud Region (e.g. us-central1, see `gcloud compute regions list`)"
}

variable "dns_zone" {
  type        = string
  description = "Google Cloud DNS Zone (e.g. google-cloud.example.com)"
}

variable "dns_zone_name" {
  type        = string
  description = "Google Cloud DNS Zone name (e.g. example-zone)"
}

# instances

variable "controller_count" {
  type        = number
  description = "Number of controllers (i.e. masters)"
  default     = 1
}

variable "worker_count" {
  type        = number
  description = "Number of workers"
  default     = 1
}

variable "controller_type" {
  type        = string
  description = "Machine type for controllers (see `gcloud compute machine-types list`)"
  default     = "n1-standard-1"
}

variable "worker_type" {
  type        = string
  description = "Machine type for controllers (see `gcloud compute machine-types list`)"
  default     = "n1-standard-1"
}

variable "os_stream" {
  type        = string
  description = "Fedora CoreOS stream for compute instances (e.g. stable, testing, next)"
  default     = "stable"

  validation {
    condition     = contains(["stable", "testing", "next"], var.os_stream)
    error_message = "The os_stream must be stable, testing, or next."
  }
}

variable "disk_size" {
  type        = number
  description = "Size of the disk in GB"
  default     = 30
}

variable "worker_preemptible" {
  type        = bool
  description = "If enabled, Compute Engine will terminate workers randomly within 24 hours"
  default     = false
}

variable "controller_snippets" {
  type        = list(string)
  description = "Controller Fedora CoreOS Config snippets"
  default     = []
}

variable "worker_snippets" {
  type        = list(string)
  description = "Worker Fedora CoreOS Config snippets"
  default     = []
}

# configuration

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel or calico)"
  default     = "calico"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR IPv4 range to assign Kubernetes pods"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
}


variable "enable_reporting" {
  type        = bool
  description = "Enable usage or analytics reporting to upstreams (Calico)"
  default     = false
}

variable "enable_aggregation" {
  type        = bool
  description = "Enable the Kubernetes Aggregation Layer (defaults to false)"
  default     = false
}

variable "worker_node_labels" {
  type        = list(string)
  description = "List of initial worker node labels"
  default     = []
}

# unofficial, undocumented, unsupported

variable "cluster_domain_suffix" {
  type        = string
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  default     = "cluster.local"
}

variable "daemonset_tolerations" {
  type        = list(string)
  description = "List of additional taint keys kube-system DaemonSets should tolerate (e.g. ['custom-role', 'gpu-role'])"
  default     = []
}
