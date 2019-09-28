module "workers" {
  source = "./workers"
  name   = var.cluster_name

  # AWS
  vpc_id          = aws_vpc.network.id
  subnet_ids      = aws_subnet.public.*.id
  security_groups = [aws_security_group.worker.id]
  worker_count    = var.worker_count
  instance_type   = var.worker_type
  os_image        = var.os_image
  disk_size       = var.disk_size
  spot_price      = var.worker_price
  target_groups   = var.worker_target_groups

  # configuration
  kubeconfig            = module.bootstrap.kubeconfig-kubelet
  ssh_authorized_key    = var.ssh_authorized_key
  service_cidr          = var.service_cidr
  cluster_domain_suffix = var.cluster_domain_suffix
  clc_snippets          = var.worker_clc_snippets
  node_labels           = var.worker_node_labels
}

