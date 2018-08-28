variable "name" {
  type        = "string"
  description = "Unique name for the worker pool"
}

# Azure

variable "region" {
  type        = "string"
  description = "Must be set to the Azure Region of cluster"
}

variable "resource_group_name" {
  type        = "string"
  description = "Must be set to the resource group name of cluster"
}

variable "subnet_id" {
  type        = "string"
  description = "Must be set to the `worker_subnet_id` output by cluster"
}

variable "security_group_id" {
  type        = "string"
  description = "Must be set to the `worker_security_group_id` output by cluster"
}

variable "backend_address_pool_id" {
  type        = "string"
  description = "Must be set to the `worker_backend_address_pool_id` output by cluster"
}

# instances

variable "count" {
  type        = "string"
  default     = "1"
  description = "Number of instances"
}

variable "vm_type" {
  type        = "string"
  default     = "Standard_F1"
  description = "Machine type for instances (see `az vm list-skus --location centralus`)"
}

variable "os_image" {
  type        = "string"
  default     = "coreos-stable"
  description = "Channel for a Container Linux derivative (coreos-stable, coreos-beta, coreos-alpha)"
}

variable "priority" {
  type        = "string"
  default     = "Regular"
  description = "Set priority to Low to use reduced cost surplus capacity, with the tradeoff that instances can be evicted at any time."
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
