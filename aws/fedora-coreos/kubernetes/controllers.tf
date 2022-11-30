# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "aws_route53_record" "etcds" {
  count = var.controller_count

  # DNS Zone where record should be created
  zone_id = var.dns_zone_id

  name = format("%s-etcd%d.%s.", var.cluster_name, count.index, var.dns_zone)
  type = "A"
  ttl  = 300

  # private IPv4 address for etcd
  records = [aws_instance.controllers.*.private_ip[count.index]]
}

# Controller instances
resource "aws_instance" "controllers" {
  count = var.controller_count

  tags = {
    Name = "${var.cluster_name}-controller-${count.index}"
  }

  instance_type = var.controller_type
  ami           = var.arch == "arm64" ? data.aws_ami.fedora-coreos-arm[0].image_id : data.aws_ami.fedora-coreos.image_id
  user_data     = data.ct_config.controllers.*.rendered[count.index]

  # storage
  root_block_device {
    volume_type = var.disk_type
    volume_size = var.disk_size
    iops        = var.disk_iops
    encrypted   = true
    tags        = {}
  }

  # network
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.public.*.id, count.index)
  vpc_security_group_ids      = [aws_security_group.controller.id]

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

# Fedora CoreOS controllers
data "ct_config" "controllers" {
  count = var.controller_count
  content = templatefile("${path.module}/butane/controller.yaml", {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = join(",", [
      for i in range(var.controller_count) : "etcd${i}=https://${var.cluster_name}-etcd${i}.${var.dns_zone}:2380"
    ])
    kubeconfig             = indent(10, module.bootstrap.kubeconfig-kubelet)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
  })
  strict   = true
  snippets = var.controller_snippets
}
