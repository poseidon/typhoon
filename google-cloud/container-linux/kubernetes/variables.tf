variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name (prepended to dns_zone)"
}

# Google Cloud

variable "region" {
  type        = "string"
  description = "Google Cloud Region (e.g. us-central1, see `gcloud compute regions list`)"
}

variable "dns_zone" {
  type        = "string"
  description = "Google Cloud DNS Zone (e.g. google-cloud.example.com)"
}

variable "dns_zone_name" {
  type        = "string"
  description = "Google Cloud DNS Zone name (e.g. example-zone)"
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

variable controller_type {
  type        = "string"
  default     = "n1-standard-1"
  description = "Machine type for controllers (see `gcloud compute machine-types list`)"
}

variable worker_type {
  type        = "string"
  default     = "n1-standard-1"
  description = "Machine type for controllers (see `gcloud compute machine-types list`)"
}

variable "os_image" {
  type        = "string"
  default     = "coreos-stable"
  description = "Container Linux image for compute instances (e.g. coreos-stable)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "Size of the disk in GB"
}

variable "worker_preemptible" {
  type        = "string"
  default     = "false"
  description = "If enabled, Compute Engine will terminate workers randomly within 24 hours"
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

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = "string"
  default     = "calico"
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
