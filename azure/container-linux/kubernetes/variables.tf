variable "location" {
  type        = "string"
  description = "Azure location to create resources"
}

variable "cluster_name" {
  type        = "string"
  description = "Cluster name"
}

variable "dns_zone" {
  type        = "string"
  description = "Azure DNS Zone (e.g., azure.typhoon.psdn.io)"
}

variable "dns_zone_rg" {
  type        = "string"
  description = "Resource group of Azure DNS zone"
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'core'"
}

variable "os_channel" {
  type        = "string"
  default     = "stable"
  description = "Container Linux AMI channel (stable, beta, alpha)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "The size of the disk in Gigabytes"
}

variable "vnet_cidr" {
  description = "CIDR IPv4 range to assign to the Virtual Network"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "controller_cidr" {
  description = "CIDR IPv4 range to assign to controller nodes"
  type        = "string"
  default     = "10.0.1.0/24"
}

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers"
}

variable "controller_type" {
  type        = "string"
  default     = "Standard_DS2_v2"
  description = "Controller VM instance type"
}

variable "worker_cidr" {
  description = "CIDR IPv4 range to assign to worker nodes"
  type        = "string"
  default     = "10.0.2.0/24"
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

variable "worker_type" {
  type        = "string"
  default     = "Standard_DS2_v2"
  description = "Worker VM instance type"
}

# bootkube assets

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (calico or flannel)"
  type        = "string"
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only). Use 8981 if using instances types with Jumbo frames."
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
