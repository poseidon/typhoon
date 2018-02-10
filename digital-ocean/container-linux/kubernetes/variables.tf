variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name"
}

variable "region" {
  type        = "string"
  description = "Digital Ocean region (e.g. nyc1, sfo2, fra1, tor1)"
}

variable "dns_zone" {
  type        = "string"
  description = "Digital Ocean domain (i.e. DNS zone) (e.g. do.example.com)"
}

variable "image" {
  type        = "string"
  default     = "coreos-stable"
  description = "OS image from which to initialize the disk (e.g. coreos-stable)"
}

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers"
}

variable "controller_type" {
  type        = "string"
  default     = "s-2vcpu-2gb"
  description = "Digital Ocean droplet size (e.g. s-2vcpu-2gb, s-2vcpu-4gb, s-4vcpu-8gb)."
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

variable "worker_type" {
  type        = "string"
  default     = "s-1vcpu-1gb"
  description = "Digital Ocean droplet size (e.g. s-1vcpu-1gb, s-1vcpu-2gb, s-2vcpu-2gb)"
}

variable "ssh_fingerprints" {
  type        = "list"
  description = "SSH public key fingerprints. (e.g. see `ssh-add -l -E md5`)"
}

# bootkube assets

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = "string"
  default     = "flannel"
}

variable "pod_cidr" {
  description = "CIDR IP range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IP range to assign Kubernetes services.
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
