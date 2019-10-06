variable "cluster_name" {
  type        = string
  description = "Unique cluster name"
}

# bare-metal

variable "matchbox_http_endpoint" {
  type        = string
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "os_stream" {
  type        = string
  description = "Fedora CoreOS release stream (e.g. testing, stable)"
  default     = "testing"
}

variable "os_version" {
  type        = string
  description = "Fedora CoreOS version to PXE and install (e.g. 30.20190712.0)"
}

# machines
# Terraform's crude "type system" does not properly support lists of maps so we do this.

variable "controller_names" {
  type        = list(string)
  description = "Ordered list of controller names (e.g. [node1])"
}

variable "controller_macs" {
  type        = list(string)
  description = "Ordered list of controller identifying MAC addresses (e.g. [52:54:00:a1:9c:ae])"
}

variable "controller_domains" {
  type        = list(string)
  description = "Ordered list of controller FQDNs (e.g. [node1.example.com])"
}

variable "worker_names" {
  type        = list(string)
  description = "Ordered list of worker names (e.g. [node2, node3])"
}

variable "worker_macs" {
  type        = list(string)
  description = "Ordered list of worker identifying MAC addresses (e.g. [52:54:00:b2:2f:86, 52:54:00:c3:61:77])"
}

variable "worker_domains" {
  type        = list(string)
  description = "Ordered list of worker FQDNs (e.g. [node2.example.com, node3.example.com])"
}

variable "snippets" {
  type        = map(list(string))
  description = "Map from machine names to lists of Fedora CoreOS Config snippets"
  default     = {}
}

# configuration

variable "k8s_domain_name" {
  type        = string
  description = "Controller DNS name which resolves to a controller instance. Workers and kubeconfig's will communicate with this endpoint (e.g. cluster.example.com)"
}

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "asset_dir" {
  type        = string
  description = "Absolute path to a directory where generated assets should be placed (contains secrets)"
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel or calico)"
  default     = "calico"
}

variable "network_mtu" {
  type        = number
  description = "CNI interface MTU (applies to calico only)"
  default     = 1480
}

variable "network_ip_autodetection_method" {
  type        = string
  description = "Method to autodetect the host IPv4 address (applies to calico only)"
  default     = "first-found"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR IPv4 range to assign Kubernetes pods"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  type = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default = "10.3.0.0/16"
}

# optional

variable "cached_install" {
  type = bool
  description = "Whether Fedora CoreOS should PXE boot and install from matchbox /assets cache. Note that the admin must have downloaded the os_version into matchbox assets."
  default = false
}

variable "install_disk" {
  type = string
  description = "Disk device to install Fedora CoreOS (e.g. sda)"
  default = "sda"
}

variable "kernel_args" {
  type = list(string)
  description = "Additional kernel arguments to provide at PXE boot."
  default = []
}

variable "enable_reporting" {
  type = bool
  description = "Enable usage or analytics reporting to upstreams (Calico)"
  default = false
}

variable "enable_aggregation" {
  type = bool
  description = "Enable the Kubernetes Aggregation Layer (defaults to false)"
  default = false
}

# unofficial, undocumented, unsupported

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type = string
  default = "cluster.local"
}

