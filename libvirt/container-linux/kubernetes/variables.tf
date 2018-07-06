# cluster-level configuration

variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name"
}

variable "base_image_path" {
  type        = "string"
  description = "Path to a downloaded and uncompressed container linux derivative image"
}

variable "k8s_domain_name" {
  description = "Controller DNS name which resolves to a controller instance. Workers and kubeconfig's will communicate with this endpoint (e.g. cluster.example.com)"
  type        = "string"
}

variable "libvirt_create_k8s_domain_name" {
  description = "Whether or not libvirt should create a record for k8s_domain_name. Set this to false if you already have a load balancing solution created."
  type = "string"
  default = "1"
}

# machines

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'core'"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

# machines

variable "machine_domain" {
  description = "the domain to use for all machine names"
  type = "string"
}

# controllers
variable "controller_names" {
  description = "list of controller hostnames (not fqdn)"
  type        = "list"
}

variable "controller_memory" {
  description = "ram to allocate in MiB for each controller"
  type        = "string"
  default     = "2048"
}

# workers
variable "worker_names" {
  description = "list of worker hostnames (not fqdn)"
  type = "list"
}

variable "worker_memory" {
  description = "ram to allocate in MiB for each worker"
  type        = "string"
  default     = "2048"
}


# Optional cluster networking configuration

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = "string"
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only)"
  type        = "string"
  default     = "1480"
}

variable "network_ip_autodetection_method" {
  description = "Method to autodetect the host IPv4 address (applies to calico only)"
  type        = "string"
  default     = "first-found"
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

# Optional libvirt configuration

variable "node_ip_pool" {
  description = "the IP pool to use for machine DHCP"
  type        = "string"
  default     = "192.168.120.0/24"
}

variable "dns_server" {
  description = "A resolving DNS server for the machines"
  type        = "string"
  default     = "8.8.8.8"
}

# optional

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}
