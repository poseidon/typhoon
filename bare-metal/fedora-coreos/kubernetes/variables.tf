variable "cluster_name" {
  type        = string
  description = "Unique cluster name"
}

# bare-metal

variable "matchbox_http_endpoint" {
  type        = string
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "os_stream" {
  type        = string
  description = "Fedora CoreOS release stream (e.g. stable, testing, next)"
  default     = "stable"

  validation {
    condition     = contains(["stable", "testing", "next"], var.os_stream)
    error_message = "The os_stream must be stable, testing, or next."
  }
}

variable "os_version" {
  type        = string
  description = "Fedora CoreOS version to PXE and install (e.g. 31.20200310.3.0)"
}

# machines

variable "controllers" {
  type = list(object({
    name   = string
    mac    = string
    domain = string
  }))
  description = <<EOD
List of controller machine details (unique name, identifying MAC address, FQDN)
[{ name = "node1", mac = "52:54:00:a1:9c:ae", domain = "node1.example.com"}]
EOD
}

variable "workers" {
  type = list(object({
    name   = string
    mac    = string
    domain = string
  }))
  description = <<EOD
List of worker machine details (unique name, identifying MAC address, FQDN)
[
  { name = "node2", mac = "52:54:00:b2:2f:86", domain = "node2.example.com"},
  { name = "node3", mac = "52:54:00:c3:61:77", domain = "node3.example.com"}
]
EOD
  default     = []
}

variable "snippets" {
  type        = map(list(string))
  description = "Map from machine names to lists of Butane snippets"
  default     = {}
}

variable "worker_node_labels" {
  type        = map(list(string))
  description = "Map from worker names to lists of initial node labels"
  default     = {}
}

variable "worker_node_taints" {
  type        = map(list(string))
  description = "Map from worker names to lists of initial node taints"
  default     = {}
}

# configuration

variable "k8s_domain_name" {
  type        = string
  description = "Controller DNS name which resolves to a controller instance. Workers and kubeconfig's will communicate with this endpoint (e.g. cluster.example.com)"
}

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel, calico, or cilium)"
  default     = "cilium"
}

variable "network_mtu" {
  type        = number
  description = "CNI interface MTU (applies to calico only)"
  default     = 1480
}

variable "network_ip_autodetection_method" {
  type        = string
  description = "Method to autodetect the host IPv4 address (applies to calico only)"
  default     = "first-found"
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

# optional

variable "cached_install" {
  type        = bool
  description = "Whether Fedora CoreOS should PXE boot and install from matchbox /assets cache. Note that the admin must have downloaded the os_version into matchbox assets."
  default     = false
}

variable "install_disk" {
  type        = string
  description = "Disk device to install Fedora CoreOS (e.g. sda)"
  default     = "sda"
}

variable "kernel_args" {
  type        = list(string)
  description = "Additional kernel arguments to provide at PXE boot."
  default     = []
}

# advanced

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
    calico     = optional(map(any))
    cilium     = optional(map(any))
  })
  default = null
}
