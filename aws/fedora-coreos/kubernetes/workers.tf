module "workers" {
  source = "./workers"
  name   = var.cluster_name

  # AWS
  vpc_id          = aws_vpc.network.id
  subnet_ids      = aws_subnet.public.*.id
  security_groups = [aws_security_group.worker.id]

  # instances
  os_stream     = var.os_stream
  worker_count  = var.worker_count
  instance_type = var.worker_type
  arch          = var.worker_arch
  disk_type     = var.worker_disk_type
  disk_size     = var.worker_disk_size
  disk_iops     = var.worker_disk_iops
  cpu_credits   = var.worker_cpu_credits
  spot_price    = var.worker_price
  target_groups = var.worker_target_groups

  # configuration
  kubeconfig         = module.bootstrap.kubeconfig-kubelet
  ssh_authorized_key = var.ssh_authorized_key
  service_cidr       = var.service_cidr
  snippets           = var.worker_snippets
  node_labels        = var.worker_node_labels
}

