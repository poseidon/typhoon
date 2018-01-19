variable "region" {
  type = "string"
  description = "The target openstack region"
}

variable "project_id" {
  type = "string"
  description = "The id of the openstack project"
}

variable "cluster_name" {
  type        = "string"
  description = "Cluster name"
}

variable "dns_zone" {
  type        = "string"
  description = "DNS Zone (e.g. kube.dghubble.io)"
  default     = ""
}

variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key for user 'core'"
}

variable "image_id" {
  description = "The id if a docker enabled image."
  default     = ""
}

variable "image_names" {
  type        = "map"
  description = "The name per region of the docker enabled images. This variable can be overriden by the \"image_id\" variable"

  default = {
    GRA1 = "CoreOS Stable"
    SBG3 = "CoreOS Stable"
    GRA3 = "CoreOS Stable"
    SBG3 = "CoreOS Stable"
    BHS3 = "CoreOS Stable"
    WAW1 = "CoreOS Stable"
    DE1  = "CoreOS Stable"
  }
}

variable "nat_flavor_name" {
  type        = "string"
  default     = "s1-2"
  description = "Nat gateways flavor name"
}

variable "bastion_flavor_name" {
  type        = "string"
  default     = "s1-2"
  description = "Bastion host flavor name"
}

variable "consul_flavor_name" {
  type        = "string"
  default     = "s1-2"
  description = "Consul server flavor name"
}

variable "lb_flavor_name" {
  type        = "string"
  default     = "s1-2"
  description = "Loab balancer flavor name"
}

variable "host_cidr" {
  description = "CIDR IPv4 range to assign to openstack instances"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers"
}

variable "apilb_count" {
  type        = "string"
  default     = "1"
  description = "Number of public facing load balancers to serve api"
}

variable "controller_flavor_name" {
  type        = "string"
  default     = "s1-2"
  description = "Controller flavor name"
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

variable "consul_server_count" {
  type = "string"
  default = "1"
  description = "Number of consul servers"
}

variable "worker_flavor_name" {
  type        = "string"
  default     = "s1-2"
  description = "Worker flavor name"
}

# bootkube assets

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (calico or flannel)"
  type        = "string"
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only). Use 8981 if using instances types with Jumbo frames."
  type        = "string"
  default     = "1480"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
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

variable "ssh_bastion_private_key" {
}

variable "ssh_private_key" {
}

variable "ssh_user" {
  default = "core"
}
variable "ssh_bastion_user" {
  default = "core"
}

variable "vlan_id" {
  description = "OVH core network vlan id"
  default     = "667"
}

variable "ovh_public_dns_server" {
  description = "OVH public dns server"
  default     = "213.186.33.99"
}
