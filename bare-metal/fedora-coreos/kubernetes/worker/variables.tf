variable "cluster_name" {
  type        = string
  description = "Must be set to the `cluster_name` of cluster"
}

# bare-metal

variable "matchbox_http_endpoint" {
  type        = string
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "os_stream" {
  type        = string
  description = "Fedora CoreOS release stream (e.g. stable, testing, next)"
  default     = "stable"

  validation {
    condition     = contains(["stable", "testing", "next"], var.os_stream)
    error_message = "The os_stream must be stable, testing, or next."
  }
}

variable "os_version" {
  type        = string
  description = "Fedora CoreOS version to PXE and install (e.g. 31.20200310.3.0)"
}

# machine

variable "name" {
  type        = string
  description = "Unique name for the machine (e.g. node1)"
}

variable "mac" {
  type        = string
  description = "MAC address (e.g. 52:54:00:a1:9c:ae)"
}

variable "domain" {
  type        = string
  description = "Fully qualified domain name (e.g. node1.example.com)"
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

variable "snippets" {
  type        = list(string)
  description = "List of Butane snippets"
  default     = []
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

# optional

variable "cached_install" {
  type        = bool
  description = "Whether Fedora CoreOS should PXE boot and install from matchbox /assets cache. Note that the admin must have downloaded the os_version into matchbox assets."
  default     = false
}

variable "install_disk" {
  type        = string
  description = "Disk device to install Fedora CoreOS (e.g. sda)"
  default     = "sda"
}

variable "kernel_args" {
  type        = list(string)
  description = "Additional kernel arguments to provide at PXE boot."
  default     = []
}

# unofficial, undocumented, unsupported

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = string
  default     = "cluster.local"
}
