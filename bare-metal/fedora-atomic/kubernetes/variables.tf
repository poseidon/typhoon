variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name"
}

# bare-metal

variable "matchbox_http_endpoint" {
  type        = "string"
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "atomic_assets_endpoint" {
  type    = "string"
  default = ""

  description = <<EOD
HTTP endpoint serving the Fedora Atomic Host vmlinuz, initrd, os repo, and ostree repo (.e.g `http://example.com/some/path`).

Ensure the HTTP server directory contains `vmlinuz` and `initrd` files and `os` and `repo` directories. Leave unset to assume ${matchbox_http_endpoint}/assets/fedora/28
EOD
}

# machines
# Terraform's crude "type system" does not properly support lists of maps so we do this.

variable "controller_names" {
  type        = "list"
  description = "Ordered list of controller names (e.g. [node1])"
}

variable "controller_macs" {
  type        = "list"
  description = "Ordered list of controller identifying MAC addresses (e.g. [52:54:00:a1:9c:ae])"
}

variable "controller_domains" {
  type        = "list"
  description = "Ordered list of controller FQDNs (e.g. [node1.example.com])"
}

variable "worker_names" {
  type        = "list"
  description = "Ordered list of worker names (e.g. [node2, node3])"
}

variable "worker_macs" {
  type        = "list"
  description = "Ordered list of worker identifying MAC addresses (e.g. [52:54:00:b2:2f:86, 52:54:00:c3:61:77])"
}

variable "worker_domains" {
  type        = "list"
  description = "Ordered list of worker FQDNs (e.g. [node2.example.com, node3.example.com])"
}

# configuration

variable "k8s_domain_name" {
  description = "Controller DNS name which resolves to a controller instance. Workers and kubeconfig's will communicate with this endpoint (e.g. cluster.example.com)"
  type        = "string"
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'fedora'"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = "string"
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only)"
  type        = "string"
  default     = "1480"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
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

variable "kernel_args" {
  description = "Additional kernel arguments to provide at PXE boot."
  type        = "list"
  default     = []
}
