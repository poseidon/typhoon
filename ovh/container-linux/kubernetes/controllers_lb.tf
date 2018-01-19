#kube-apiserver DNS Record
locals {
  api_dns_subdomain = "${replace(var.cluster_name, "_", "-")}-api"
}

resource "ovh_domain_zone_record" "apiserver" {
  count     = "${var.dns_zone != "" ? var.apilb_count : 0 }"
  zone      = "${var.dns_zone}"
  subdomain = "${local.api_dns_subdomain}"
  target    = "${element(module.loadbalancers.public_ipv4_addrs, count.index)}"
  fieldtype = "A"
  ttl       = 3600
}

module "loadbalancers" {
  source                    = "ovh/publiccloud-consul/ovh"
  version                   = ">= 0.0.22"
  count                     = "${var.apilb_count}"
  name                      = "${var.cluster_name}_lb"
  cidr                      = "${var.host_cidr}"
  region                    = "${var.region}"
  datacenter                = "${lower(var.region)}"
  network_id                = "${module.network.network_id}"
  subnet_ids                = ["${module.network.public_subnets[0]}"]
  ssh_public_keys           = ["${var.ssh_authorized_key}"]
  agent_mode                = "client"
  image_name                = "CoreOS Stable"
  flavor_name               = "${var.lb_flavor_name}"
  ignition_mode             = true
  post_install_modules      = true
  ssh_user                  = "core"
  ssh_bastion_host          = "${module.admin_network.bastion_public_ip}"
  ssh_bastion_user          = "core"
  ssh_private_key           = "${var.ssh_private_key}"
  ssh_bastion_private_key   = "${var.ssh_bastion_private_key}"

  join_ipv4_addr            = ["${module.consul_servers.ipv4_addrs}"]
  public_security_group_ids = ["${openstack_networking_secgroup_v2.controller_pub.id}"]
  associate_public_ipv4     = true

  # as of today, this is not used but soon will be, so variable is made mandatory to
  # avoid future breaking change.
  cluster_tag_value = "${var.cluster_name}"

  additional_filepaths    = ["/etc/sysconfig/fabio_apiserver.conf"]
  additional_filecontents = ["FABIO_PROXY_ADDR=':443;proto=tcp'"]
  provision_remote_exec   = [
    "sudo systemctl enable fabio@apiserver.service",
    "sudo systemctl start fabio@apiserver.service"
  ]


  metadata = {
    Terraform   = "true"
    Type        = "Load balancer"
    Environment = "Kubernetes Typhoon ${var.cluster_name}"
  }
}
