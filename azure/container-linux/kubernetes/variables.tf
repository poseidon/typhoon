variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name (prepended to dns_zone)"
}

# Azure

variable "region" {
  type        = "string"
  description = "Azure Region (e.g. centralus , see `az account list-locations --output table`)"
}

variable "dns_zone" {
  type        = "string"
  description = "Azure DNS Zone (e.g. azure.example.com)"
}

variable "dns_zone_group" {
  type        = "string"
  description = "Resource group where the Azure DNS Zone resides (e.g. global)"
}

# instances

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers (i.e. masters)"
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

variable "controller_type" {
  type        = "string"
  default     = "Standard_DS1_v2"
  description = "Machine type for controllers (see `az vm list-skus --location centralus`)"
}

variable "worker_type" {
  type        = "string"
  default     = "Standard_F1"
  description = "Machine type for workers (see `az vm list-skus --location centralus`)"
}

variable "os_image" {
  type        = "string"
  default     = "coreos-stable"
  description = "Channel for a Container Linux derivative (coreos-stable, coreos-beta, coreos-alpha)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "Size of the disk in GB"
}

variable "worker_priority" {
  type        = "string"
  default     = "Regular"
  description = "Set worker priority to Low to use reduced cost surplus capacity, with the tradeoff that instances can be deallocated at any time."
}

variable "controller_clc_snippets" {
  type        = "list"
  description = "Controller Container Linux Config snippets"
  default     = []
}

variable "worker_clc_snippets" {
  type        = "list"
  description = "Worker Container Linux Config snippets"
  default     = []
}

# configuration

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'core'"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "host_cidr" {
  description = "CIDR IPv4 range to assign to instances"
  type        = "string"
  default     = "10.0.0.0/16"
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
