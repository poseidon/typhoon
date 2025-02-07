variable "cluster_name" {
  type        = string
  description = "Unique cluster name (prepended to dns_zone)"
}

# Azure

variable "location" {
  type        = string
  description = "Azure location (e.g. centralus , see `az account list-locations --output table`)"
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

variable "os_image" {
  type        = string
  description = "Fedora CoreOS image for instances"
}

variable "controller_count" {
  type        = number
  description = "Number of controllers (i.e. masters)"
  default     = 1
}

variable "controller_type" {
  type        = string
  description = "Machine type for controllers (see `az vm list-skus --location centralus`)"
  default     = "Standard_B2s"
}

variable "controller_disk_type" {
  type        = string
  description = "Type of managed disk for controller node(s)"
  default     = "Premium_LRS"
}

variable "controller_disk_size" {
  type        = number
  description = "Size of the managed disk in GB for controller node(s)"
  default     = 30
}

variable "worker_count" {
  type        = number
  description = "Number of workers"
  default     = 1
}

variable "worker_type" {
  type        = string
  description = "Machine type for workers (see `az vm list-skus --location centralus`)"
  default     = "Standard_D2as_v5"
}

variable "worker_disk_type" {
  type        = string
  description = "Type of managed disk for worker nodes"
  default     = "Standard_LRS"
}

variable "worker_disk_size" {
  type        = number
  description = "Size of the managed disk in GB for worker nodes"
  default     = 30
}

variable "worker_ephemeral_disk" {
  type        = bool
  description = "Use ephemeral local disk instead of managed disk (requires vm_type with local storage)"
  default     = false
}

variable "worker_priority" {
  type        = string
  description = "Set worker priority to Spot to use reduced cost surplus capacity, with the tradeoff that instances can be deallocated at any time."
  default     = "Regular"
}

variable "controller_snippets" {
  type        = list(string)
  description = "Controller Butane snippets"
  default     = []
}

variable "worker_snippets" {
  type        = list(string)
  description = "Worker Butane snippets"
  default     = []
}

# configuration

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for user 'core'"
}

variable "azure_authorized_key" {
  type        = string
  description = "Optionally, pass a dummy RSA key to satisfy Azure validations (then use an ed25519 key set above)"
  default     = ""
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel or cilium)"
  default     = "cilium"
}

variable "network_cidr" {
  type = object({
    ipv4 = list(string)
    ipv6 = optional(list(string), [])
  })
  description = "Virtual network CIDR ranges"
  default = {
    ipv4 = ["10.0.0.0/16"]
  }
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

variable "enable_ipv6_load_balancing" {
  description = "Enable IPv6 LB rules (note: Azure charges ~$20/mo more)"
  default     = false
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
