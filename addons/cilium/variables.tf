variable "pod_cidr" {
  type        = string
  description = "CIDR IP range to assign Kubernetes pods"
  default     = "10.2.0.0/16"
}

variable "daemonset_tolerations" {
  type        = list(string)
  description = "List of additional taint keys kube-system DaemonSets should tolerate (e.g. ['custom-role', 'gpu-role'])"
  default     = []
}

variable "enable_hubble" {
  type        = bool
  description = "Run the embedded Hubble Server and mount hubble-server-certs Secret"
  default     = true
}
