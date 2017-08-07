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
  description = "Digital Ocean domain name (i.e. DNS zone with NS records) (e.g. digital-ocean.dghubble.io)"
}

variable "image" {
  type        = "string"
  description = "OS image from which to initialize the disk (e.g. coreos-stable)"
}

variable "controller_type" {
  type        = "string"
  default     = "1gb"
  description = "Digital Ocean droplet type or size (e.g. 2gb, 4gb, 8gb). Do not choose a value below 2gb."
}

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers"
}

variable "worker_type" {
  type        = "string"
  default     = "512mb"
  description = "Digital Ocean droplet type or size (e.g. 512mb, 1gb, 2gb, 4gb)"
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

variable "ssh_fingerprints" {
  type        = "list"
  description = "SSH public key fingerprints. Use ssh-add -l -E md5."
}

# bootkube assets

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "pod_cidr" {
  description = "CIDR IP range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IP range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns, the 15th IP will be reserved for self-hosted etcd, and the 200th IP will be reserved for bootstrap self-hosted etcd.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}
