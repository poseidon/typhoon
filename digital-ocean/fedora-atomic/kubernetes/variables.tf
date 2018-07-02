variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name (prepended to dns_zone)"
}

# Digital Ocean

variable "region" {
  type        = "string"
  description = "Digital Ocean region (e.g. nyc1, sfo2, fra1, tor1)"
}

variable "dns_zone" {
  type        = "string"
  description = "Digital Ocean domain (i.e. DNS zone) (e.g. do.example.com)"
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

variable "controller_type" {
  type        = "string"
  default     = "s-2vcpu-2gb"
  description = "Droplet type for controllers (e.g. s-2vcpu-2gb, s-2vcpu-4gb, s-4vcpu-8gb)"
}

variable "worker_type" {
  type        = "string"
  default     = "s-1vcpu-1gb"
  description = "Droplet type for workers (e.g. s-1vcpu-1gb, s-1vcpu-2gb, s-2vcpu-2gb)"
}

variable "image" {
  type        = "string"
  default     = "fedora-28-x64-atomic"
  description = "OS image from which to initialize the disk (e.g. fedora-28-x64-atomic)"
}

# configuration

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'fedora'"
}

variable "ssh_fingerprints" {
  type        = "list"
  description = "SSH public key fingerprints. (e.g. see `ssh-add -l -E md5`)"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}
