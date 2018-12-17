module "workers" {
  source = "workers"
  name   = "${var.cluster_name}"

  # AWS
  vpc_id          = "${local.manage_vpc ? join("", aws_vpc.network.*.id) : var.vpc_id}"
  subnet_ids      = ["${split(":", length(var.public_subnets) > 0 ? join(":", var.public_subnets) : join(":", aws_subnet.public.*.id))}"]
  security_groups = ["${aws_security_group.worker.id}"]
  count           = "${var.worker_count}"
  instance_type   = "${var.worker_type}"
  os_image        = "${var.os_image}"
  disk_size       = "${var.disk_size}"
  spot_price      = "${var.worker_price}"

  # configuration
  kubeconfig            = "${module.bootkube.kubeconfig-kubelet}"
  ssh_authorized_key    = "${var.ssh_authorized_key}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  clc_snippets          = "${var.worker_clc_snippets}"
}
