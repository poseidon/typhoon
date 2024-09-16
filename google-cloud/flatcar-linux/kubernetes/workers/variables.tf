variable "name" {
  type        = string
  description = "Unique name for the worker pool"
}

variable "cluster_name" {
  type        = string
  description = "Must be set to `cluster_name of cluster`"
}

# Google Cloud

variable "region" {
  type        = string
  description = "Must be set to `region` of cluster"
}

variable "network" {
  type        = string
  description = "Must be set to `network_name` output by cluster"
}

# instances

variable "worker_count" {
  type        = number
  description = "Number of worker compute instances the instance group should manage"
  default     = 1
}

variable "machine_type" {
  type        = string
  description = "Machine type for compute instances (e.g. gcloud compute machine-types list)"
  default     = "n1-standard-1"
}

variable "os_image" {
  type        = string
  description = "Flatcar Linux image for compute instances (flatcar-stable, flatcar-beta, flatcar-alpha)"
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

variable "disk_type" {
  type        = string
  description = "Type of managed disk"
  default     = "pd-standard"
  validation {
    condition     = contains(["pd-standard", "pd-ssd", "pd-balanced"], var.disk_type)
    error_message = "The disk_type must be pd-standard, pd-ssd or pd-balanced."
  }
}

variable "preemptible" {
  type        = bool
  description = "If enabled, Compute Engine will terminate instances randomly within 24 hours"
  default     = false
}

variable "snippets" {
  type        = list(string)
  description = "Container Linux Config snippets"
  default     = []
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

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
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

# advanced

variable "accelerator_type" {
  type        = string
  default     = ""
  description = "Google Compute Engine accelerator type (e.g. nvidia-tesla-k80, see gcloud compute accelerator-types list)"
}

variable "accelerator_count" {
  type        = string
  default     = "0"
  description = "Number of compute engine accelerators"
}
