# Network
# Design considerations:
# OVH doesn't provide neither managed private dns service nor managed private lb.
# Yet such feature is on OVH public cloud roadmap. Meanwhile we can address this issue by spawning a consul cluster which can act as a private dns service
# and rely on dns round robin resolution to act as a private lb.
# But we won't fullfill consul's philosophy by deploying a consul agent on every kubernetes node because we want to be able to replace it
# by a proper load balancer & dns private service with minimum impact
# on the kubernetes deployment.

# To achieve this, we will create an admin network subnet, spawn the consul
# cluster within this subnet, and use consul nodes IPv4s as dns servers for
# kubernetes subnets
# thus we can register etcd and kubernetes services in consul with simple ssh post provisioners

# make use of the ovh api to set a vlan id (or segmentation id)
resource "ovh_publiccloud_private_network" "core_net" {
  project_id = "${var.project_id}"
  name       = "${var.cluster_name}"
  regions    = ["${var.region}"]
  vlan_id    = "${var.vlan_id}"
}

module "admin_network" {
  source  = "ovh/publiccloud-network/ovh"
  version = ">= 0.0.18"

  attach_vrack                 = false
  project_id                   = "${var.project_id}"
  name                         = "${var.cluster_name}_admin"
  cidr                         = "${var.host_cidr}"
  region                       = "${var.region}"
  create_network               = false
  network_name                 = "${ovh_publiccloud_private_network.core_net.name}"
  public_subnets               = ["${cidrsubnet(var.host_cidr, 4, 0)}"]
  private_subnets              = ["${cidrsubnet(var.host_cidr, 4, 1)}"]
  enable_bastion_host          = true
  enable_nat_gateway           = true
  ssh_public_keys              = ["${var.ssh_authorized_key}"]
  nat_instance_flavor_name     = "${var.nat_flavor_name}"
  bastion_instance_flavor_name = "${var.bastion_flavor_name}"

  metadata = {
    Name = "${var.cluster_name}_admin"
  }
}

module "consul_servers" {
  source  = "ovh/publiccloud-consul/ovh"
  version = ">= 0.0.22"

  #  source = "git::https://github.com/ovh/terraform-ovh-publiccloud-consul.git"
  count                   = "${var.consul_server_count}"
  name                    = "${var.cluster_name}_consul_servers"
  cidr                    = "${var.host_cidr}"
  region                  = "${var.region}"
  datacenter              = "${lower(var.region)}"
  network_id              = "${module.admin_network.network_id}"
  subnet_ids              = ["${module.admin_network.private_subnets[0]}"]
  ssh_public_keys         = ["${var.ssh_authorized_key}"]
  flavor_name             = "${var.consul_flavor_name}"
  image_name              = "CoreOS Stable"
  ignition_mode           = true
  post_install_modules    = true
  ssh_user                = "core"
  ssh_bastion_host        = "${module.admin_network.bastion_public_ip}"
  ssh_bastion_user        = "core"
  ssh_private_key         = "${var.ssh_private_key}"
  ssh_bastion_private_key = "${var.ssh_bastion_private_key}"

  # as of today, this is not used but soon will be, so variable is made mandatory to
  # avoid future breaking change.
  cluster_tag_value = "${var.cluster_name}"

  metadata = {
    Terraform   = "true"
    Environment = "Kubernetes Typhoon ${var.cluster_name}"
  }
}

module "network" {
  source  = "ovh/publiccloud-network/ovh"
  version = ">= 0.0.18"

  attach_vrack                 = false
  create_network               = false
  network_name                 = "${ovh_publiccloud_private_network.core_net.name}"
  project_id                   = "${var.project_id}"
  name                         = "${var.cluster_name}"
  cidr                         = "${var.host_cidr}"
  region                       = "${var.region}"
  public_subnets               = ["${cidrsubnet(var.host_cidr, 4, 2)}"]
  private_subnets              = ["${cidrsubnet(var.host_cidr, 4, 3)}"]
  nat_instance_flavor_name     = "${var.nat_flavor_name}"
  bastion_instance_flavor_name = "${var.bastion_flavor_name}"

  enable_nat_gateway = true
  dns_nameservers    = ["${module.consul_servers.ipv4_addrs}", "${var.ovh_public_dns_server}"]

  metadata = {
    Name = "${var.cluster_name}"
  }
}
