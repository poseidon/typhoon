variable "replicas" {
  type        = number
  description = "CoreDNS replica count"
  default     = 2
}

variable "cluster_dns_service_ip" {
  description = "Must be set to `cluster_dns_service_ip` output by cluster"
  default     = "10.3.0.10"
}

variable "cluster_domain_suffix" {
  description = "Must be set to `cluster_domain_suffix` output by cluster"
  default     = "cluster.local"
}
