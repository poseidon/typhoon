module "workers" {
  count  = length(var.workers)
  source = "./worker"

  cluster_name = var.cluster_name

  # metal
  matchbox_http_endpoint = var.matchbox_http_endpoint
  os_channel             = var.os_channel
  os_version             = var.os_version

  # machine
  name   = var.workers[count.index].name
  mac    = var.workers[count.index].mac
  domain = var.workers[count.index].domain

  # configuration
  kubeconfig            = module.bootstrap.kubeconfig-kubelet
  ssh_authorized_key    = var.ssh_authorized_key
  service_cidr          = var.service_cidr
  cluster_domain_suffix = var.cluster_domain_suffix
  node_labels           = lookup(var.worker_node_labels, var.workers[count.index].name, [])
  node_taints           = lookup(var.worker_node_taints, var.workers[count.index].name, [])
  snippets              = lookup(var.snippets, var.workers[count.index].name, [])

  # optional
  download_protocol = var.download_protocol
  cached_install    = var.cached_install
  install_disk      = var.install_disk
  kernel_args       = var.kernel_args
  oem_type          = var.oem_type
}

