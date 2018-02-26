variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name"
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for logging in as user 'core'"
}

variable "network" {
  type        = "string"
  description = "Name of the network to attach to the compute instance interfaces"
}

# instances

variable "count" {
  type        = "string"
  default     = "1"
  description = "Number of worker compute instances the instance group should manage"
}

variable "region" {
  type        = "string"
  description = "Google Cloud region (e.g. us-central1, see `gcloud compute regions list`)."
}

variable "machine_type" {
  type        = "string"
  default     = "n1-standard-1"
  description = "Machine type for compute instances (e.g. gcloud compute machine-types list)"
}

variable "os_image" {
  type        = "string"
  default     = "coreos-stable"
  description = "OS image from which to initialize the disk (e.g. gcloud compute images list)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "The size of the disk in gigabytes."
}

variable "preemptible" {
  type        = "string"
  default     = "false"
  description = "If enabled, Compute Engine will terminate instances randomly within 24 hours"
}

# configuration

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

variable "kubeconfig" {
  type        = "string"
  description = "Generated Kubelet kubeconfig"
}
