variable "cluster_name" {
  type        = string
  description = "Must be set to the `cluster_name` of cluster"
}

# bare-metal

variable "matchbox_http_endpoint" {
  type        = string
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "os_channel" {
  type        = string
  description = "Channel for a Flatcar Linux (flatcar-stable, flatcar-beta, flatcar-alpha)"

  validation {
    condition     = contains(["flatcar-stable", "flatcar-beta", "flatcar-alpha"], var.os_channel)
    error_message = "The os_channel must be flatcar-stable, flatcar-beta, or flatcar-alpha."
  }
}

variable "os_version" {
  type        = string
  description = "Version of Flatcar Linux to PXE and install (e.g. 2079.5.1)"
}

# machine

variable "name" {
  type        = string
  description = "Unique name for the machine (e.g. node1)"
}

variable "mac" {
  type        = string
  description = "MAC address (e.g. 52:54:00:a1:9c:ae)"
}

variable "domain" {
  type        = string
  description = "Fully qualified domain name (e.g. node1.example.com)"
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

variable "snippets" {
  type        = list(string)
  description = "List of Butane snippets"
  default     = []
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

# optional

variable "download_protocol" {
  type        = string
  description = "Protocol iPXE should use to download the kernel and initrd. Defaults to https, which requires iPXE compiled with crypto support. Unused if cached_install is true."
  default     = "https"
}

variable "cached_install" {
  type        = bool
  description = "Whether Flatcar Linux should PXE boot and install from matchbox /assets cache. Note that the admin must have downloaded the os_version into matchbox assets."
  default     = false
}

variable "install_disk" {
  type        = string
  default     = "/dev/sda"
  description = "Disk device to which the install profiles should install Flatcar Linux (e.g. /dev/sda)"
}

variable "kernel_args" {
  type        = list(string)
  description = "Additional kernel arguments to provide at PXE boot."
  default     = []
}

variable "os_architecture" {
  type        = string
  description = "CPU architecture of the node"
  default     = "amd64"
}

# unofficial, undocumented, unsupported

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
}



variable "cluster_domain_suffix" {
  type        = string
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  default     = "cluster.local"
}


