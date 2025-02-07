variable "cluster_name" {
  type        = string
  description = "Unique cluster name (prepended to dns_zone)"
}

# Google Cloud

variable "region" {
  type        = string
  description = "Google Cloud Region (e.g. us-central1, see `gcloud compute regions list`)"
}

variable "dns_zone" {
  type        = string
  description = "Google Cloud DNS Zone (e.g. google-cloud.example.com)"
}

variable "dns_zone_name" {
  type        = string
  description = "Google Cloud DNS Zone name (e.g. example-zone)"
}

# instances

variable "os_image" {
  type        = string
  description = "Flatcar Linux image for compute instances (flatcar-stable, flatcar-beta, flatcar-alpha)"
  default     = "flatcar-stable"

  validation {
    condition     = contains(["flatcar-stable", "flatcar-beta", "flatcar-alpha"], var.os_image)
    error_message = "The os_image must be flatcar-stable, flatcar-beta, or flatcar-alpha."
  }
}

variable "controller_count" {
  type        = number
  description = "Number of controllers (i.e. masters)"
  default     = 1
}

variable "controller_type" {
  type        = string
  description = "Machine type for controllers (see `gcloud compute machine-types list`)"
  default     = "n1-standard-1"
}

variable "controller_disk_size" {
  type        = number
  description = "Size of the disk in GB"
  default     = 30
}

variable "controller_disk_type" {
  type        = string
  description = "Type of managed disk for controller node(s)"
  default     = "pd-standard"
  validation {
    condition     = contains(["pd-standard", "pd-ssd", "pd-balanced"], var.controller_disk_type)
    error_message = "The controller_disk_type must be pd-standard, pd-ssd or pd-balanced."
  }
}

variable "worker_count" {
  type        = number
  description = "Number of workers"
  default     = 1
}

variable "worker_type" {
  type        = string
  description = "Machine type for controllers (see `gcloud compute machine-types list`)"
  default     = "n1-standard-1"
}

variable "worker_disk_size" {
  type        = number
  description = "Size of the disk in GB"
  default     = 30
}

variable "worker_disk_type" {
  type        = string
  description = "Type of managed disk for worker nodes"
  default     = "pd-standard"
  validation {
    condition     = contains(["pd-standard", "pd-ssd", "pd-balanced"], var.worker_disk_type)
    error_message = "The worker_disk_type must be pd-standard, pd-ssd or pd-balanced."
  }
}

variable "worker_preemptible" {
  type        = bool
  description = "If enabled, Compute Engine will terminate workers randomly within 24 hours"
  default     = false
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
  description = "Choice of networking provider (flannel or cilium)"
  default     = "cilium"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR IPv4 range to assign Kubernetes pods"
  default     = "10.20.0.0/14"
}

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
}

variable "worker_node_labels" {
  type        = list(string)
  description = "List of initial worker node labels"
  default     = []
}

# advanced

variable "daemonset_tolerations" {
  type        = list(string)
  description = "List of additional taint keys kube-system DaemonSets should tolerate (e.g. ['custom-role', 'gpu-role'])"
  default     = []
}

variable "components" {
  description = "Configure pre-installed cluster components"
  # Component configs are passed through to terraform-render-bootstrap,
  # which handles type enforcement and defines defaults
  # https://github.com/poseidon/terraform-render-bootstrap/blob/main/variables.tf#L95
  type = object({
    enable     = optional(bool)
    coredns    = optional(map(any))
    kube_proxy = optional(map(any))
    flannel    = optional(map(any))
    cilium     = optional(map(any))
  })
  default = null
}

variable "service_account_issuer" {
  type        = string
  description = "kube-apiserver service account token issuer (used as an identifier in 'iss' claims)"
  default     = "https://kubernetes.default.svc.cluster.local"
}
