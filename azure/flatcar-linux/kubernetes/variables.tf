variable "cluster_name" {
  type        = string
  description = "Unique cluster name (prepended to dns_zone)"
}

# Azure

variable "region" {
  type        = string
  description = "Azure Region (e.g. centralus , see `az account list-locations --output table`)"
}

variable "dns_zone" {
  type        = string
  description = "Azure DNS Zone (e.g. azure.example.com)"
}

variable "dns_zone_group" {
  type        = string
  description = "Resource group where the Azure DNS Zone resides (e.g. global)"
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
  description = "Machine type for controllers (see `az vm list-skus --location centralus`)"
  default     = "Standard_B2s"
}

variable "worker_type" {
  type        = string
  description = "Machine type for workers (see `az vm list-skus --location centralus`)"
  default     = "Standard_DS1_v2"
}

variable "os_image" {
  type        = string
  description = "Channel for a Container Linux derivative (flatcar-stable, flatcar-beta, flatcar-alpha)"
  default     = "flatcar-stable"

  validation {
    condition     = contains(["flatcar-stable", "flatcar-beta", "flatcar-alpha"], var.os_image)
    error_message = "The os_image must be flatcar-stable, flatcar-beta, or flatcar-alpha."
  }
}

variable "disk_size" {
  type        = number
  description = "Size of the disk in GB"
  default     = 30
}

variable "worker_priority" {
  type        = string
  description = "Set worker priority to Spot to use reduced cost surplus capacity, with the tradeoff that instances can be deallocated at any time."
  default     = "Regular"
}

variable "controller_snippets" {
  type        = list(string)
  description = "Controller Container Linux Config snippets"
  default     = []
}

variable "worker_snippets" {
  type        = list(string)
  description = "Worker Container Linux Config snippets"
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

variable "host_cidr" {
  type        = string
  description = "CIDR IPv4 range to assign to instances"
  default     = "10.0.0.0/16"
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
