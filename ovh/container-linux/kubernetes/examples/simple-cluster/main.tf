provider "openstack" {
  version = "~> 1.1.1"
  region  = "${var.region}"
}

provider "ovh" {
  version = "~> 0.2"
}

variable "region" {
  type        = "string"
  description = "The target openstack region"
  default     = "GRA3"
}

variable "project_id" {
  type        = "string"
  description = "The id of the openstack project"
}

module "kube" {
  source       = "../.."
  region       = "${var.region}"
  project_id   = "${var.project_id}"
  cluster_name = "DemoOVHkube"

  #  dns_zone           = "parasitid.ovh"
  ssh_authorized_key      = "${file("~/.ssh/id_rsa.pub")}"
  worker_count            = 3
  controller_count        = 3
  asset_dir               = "./assets"
  ssh_bastion_private_key = "${file("~/.ssh/id_rsa")}"
  ssh_private_key         = "${file("~/.ssh/id_rsa")}"

  nat_flavor_name        = "b2-7"
  bastion_flavor_name    = "b2-7"
  consul_flavor_name     = "b2-7"
  lb_flavor_name         = "b2-7"
  worker_flavor_name     = "b2-7"
  controller_flavor_name = "b2-7"
}
