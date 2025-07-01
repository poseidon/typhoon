variable "name" {
  type        = string
  description = "Unique name for the worker pool"
}

# Azure

variable "location" {
  type        = string
  description = "Must be set to the Azure location of cluster"
}

variable "resource_group_name" {
  type        = string
  description = "Must be set to the resource group name of cluster"
}

variable "subnet_id" {
  type        = string
  description = "Must be set to the `worker_subnet_id` output by cluster"
}

variable "security_group_id" {
  type        = string
  description = "Must be set to the `worker_security_group_id` output by cluster"
}

variable "backend_address_pool_ids" {
  type = object({
    ipv4 = list(string)
    ipv6 = list(string)
  })
  description = "Must be set to the `backend_address_pool_ids` output by cluster"
}

# instances

variable "worker_count" {
  type        = number
  description = "Number of instances"
  default     = 1
}

variable "vm_type" {
  type        = string
  description = "Machine type for instances (see `az vm list-skus --location centralus`)"
  default     = "Standard_D2as_v5"
}

variable "os_image" {
  type        = string
  description = "Fedora CoreOS image for instances"
}

variable "disk_type" {
  type        = string
  description = "Type of managed disk"
  default     = "Standard_LRS"
}

variable "disk_size" {
  type        = number
  description = "Size of the managed disk in GB"
  default     = 30
}

variable "ephemeral_disk" {
  type        = bool
  description = "Use ephemeral local disk instead of managed disk (requires vm_type with local storage)"
  default     = false
}

variable "ephemeral_disk_placement" {
  type        = string
  description = "Ephemeral disk placement setting"
  default     = "ResourceDisk"
  validation {
    condition     = contains(["ResourceDisk", "NvmeDisk"], var.ephemeral_disk_placement)
    error_message = "ephemeral_placement must be ResourceDisk or NvmeDisk."
  }
}

variable "priority" {
  type        = string
  description = "Set priority to Spot to use reduced cost surplus capacity, with the tradeoff that instances can be evicted at any time."
  default     = "Regular"
}

variable "snippets" {
  type        = list(string)
  description = "Butane snippets"
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

variable "azure_authorized_key" {
  type        = string
  description = "Optionally, pass a dummy RSA key to satisfy Azure validations (then use an ed25519 key set above)"
  default     = ""
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
