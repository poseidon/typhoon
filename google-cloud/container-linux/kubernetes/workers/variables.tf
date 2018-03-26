variable "name" {
  type        = "string"
  description = "Unique name for the worker pool"
}

variable "cluster_name" {
  type        = "string"
  description = "Must be set to `cluster_name of cluster`"
}

# Google Cloud

variable "region" {
  type        = "string"
  description = "Must be set to `region` of cluster"
}

variable "network" {
  type        = "string"
  description = "Must be set to `network_name` output by cluster"
}

# instances

variable "count" {
  type        = "string"
  default     = "1"
  description = "Number of worker compute instances the instance group should manage"
}

variable "machine_type" {
  type        = "string"
  default     = "n1-standard-1"
  description = "Machine type for compute instances (e.g. gcloud compute machine-types list)"
}

variable "os_image" {
  type        = "string"
  default     = "coreos-stable"
  description = "Container Linux image for compute instanges (e.g. gcloud compute images list)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "Size of the disk in GB"
}

variable "preemptible" {
  type        = "string"
  default     = "false"
  description = "If enabled, Compute Engine will terminate instances randomly within 24 hours"
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

variable "clc_snippets" {
  type        = "list"
  description = "Container Linux Config snippets"
  default     = []
}

# unofficial, undocumented, unsupported, temporary

variable "accelerator_type" {
  type        = "string"
  default     = ""
  description = "Google Compute Engine accelerator type (e.g. nvidia-tesla-k80, see gcloud compute accelerator-types list)"
}

variable "accelerator_count" {
  type        = "string"
  default     = "0"
  description = "Number of compute engine accelerators"
}
