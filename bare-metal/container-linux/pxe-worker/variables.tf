variable "cluster_name" {
  description = "Cluster name"
  type        = "string"
}

variable "matchbox_http_endpoint" {
  type        = "string"
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "container_linux_channel" {
  type        = "string"
  description = "Container Linux channel corresponding to the container_linux_version"
}

variable "container_linux_version" {
  type        = "string"
  description = "Container Linux version of the kernel/initrd to PXE or the image to install"
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key to set as an authorized key"
}

# machines
# Terraform's crude "type system" does properly support lists of maps so we do this.

variable "controller_domains" {
  type = "list"
}

variable "worker_names" {
  type = "list"
}

variable "worker_macs" {
  type = "list"
}

variable "worker_domains" {
  type = "list"
}

# bootkube

variable "kubeconfig" {
  type = "string"
}

variable "kube_dns_service_ip" {
  description = "Kubernetes service IP for kube-dns (must be within server_cidr)"
  type        = "string"
  default     = "10.3.0.10"
}

# optional

variable "kernel_args" {
  description = "Additional kernel arguments to provide at PXE boot."
  type        = "list"

  default = [
    "root=/dev/sda1",
  ]
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by kube-dns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}
