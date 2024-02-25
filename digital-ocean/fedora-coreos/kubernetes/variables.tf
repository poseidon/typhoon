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
  description = "Fedora CoreOS image for instances"
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

variable "ssh_fingerprints" {
  type        = list(string)
  description = "SSH public key fingerprints. (e.g. see `ssh-add -l -E md5`)"
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel, calico, or cilium)"
  default     = "cilium"
}

variable "install_container_networking" {
  type        = bool
  description = "Install the chosen networking provider during cluster bootstrap (use false to self-manage)"
  default     = true
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
  description = "Enable the Kubernetes Aggregation Layer"
  default     = true
}

# unofficial, undocumented, unsupported

variable "cluster_domain_suffix" {
  type        = string
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  default     = "cluster.local"
}

