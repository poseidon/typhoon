variable "cluster_name" {
  type        = string
  description = "Unique cluster name (prepended to dns_zone)"
}

# Digital Ocean

variable "region" {
  type        = string
  description = "Digital Ocean region (e.g. nyc1, sfo2, fra1, tor1)"
}

variable "dns_zone" {
  type        = string
  description = "Digital Ocean domain (i.e. DNS zone) (e.g. do.example.com)"
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
  description = "Droplet type for controllers (e.g. s-2vcpu-2gb, s-2vcpu-4gb, s-4vcpu-8gb)."
  default     = "s-2vcpu-2gb"
}

variable "worker_type" {
  type        = string
  description = "Droplet type for workers (e.g. s-1vcpu-2gb, s-2vcpu-2gb)"
  default     = "s-1vcpu-2gb"
}

variable "os_image" {
  type        = string
  description = "Flatcar Linux image for instances (e.g. custom-image-id)"
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

variable "ssh_fingerprints" {
  type        = list(string)
  description = "SSH public key fingerprints. (e.g. see `ssh-add -l -E md5`)"
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel, calico, or cilium)"
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
