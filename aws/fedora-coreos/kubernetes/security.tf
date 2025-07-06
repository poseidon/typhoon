# Security Groups (instance firewalls)

# Controller security group

resource "aws_security_group" "controller" {
  name        = "${var.cluster_name}-controller"
  description = "${var.cluster_name} controller security group"

  vpc_id = aws_vpc.network.id

  tags = {
    "Name" = "${var.cluster_name}-controller"
  }
}

resource "aws_security_group_rule" "controller-icmp" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "icmp"
  from_port                = 8
  to_port                  = 0
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "controller-icmp-self" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.controller.id

  type      = "ingress"
  protocol  = "icmp"
  from_port = 8
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "controller-ssh" {
  security_group_id = aws_security_group.controller.id

  type             = "ingress"
  protocol         = "tcp"
  from_port        = 22
  to_port          = 22
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "controller-etcd" {
  security_group_id = aws_security_group.controller.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

# Allow Prometheus to scrape etcd metrics
resource "aws_security_group_rule" "controller-etcd-metrics" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2381
  to_port                  = 2381
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "controller-cilium-health" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 4240
  to_port                  = 4240
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "controller-cilium-health-self" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.controller.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 4240
  to_port   = 4240
  self      = true
}

resource "aws_security_group_rule" "controller-cilium-metrics" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9962
  to_port                  = 9965
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "controller-cilium-metrics-self" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.controller.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 9962
  to_port   = 9965
  self      = true
}

resource "aws_security_group_rule" "controller-apiserver" {
  security_group_id = aws_security_group.controller.id

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 6443
  to_port     = 6443
  cidr_blocks = ["0.0.0.0/0"]
}

# Linux VXLAN default
resource "aws_security_group_rule" "controller-vxlan" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8472
  to_port                  = 8472
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "controller-vxlan-self" {
  security_group_id = aws_security_group.controller.id

  type      = "ingress"
  protocol  = "udp"
  from_port = 8472
  to_port   = 8472
  self      = true
}

# Allow Prometheus to scrape node-exporter daemonset
resource "aws_security_group_rule" "controller-node-exporter" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9100
  to_port                  = 9100
  source_security_group_id = aws_security_group.worker.id
}

# Allow Prometheus to scrape kube-proxy
resource "aws_security_group_rule" "kube-proxy-metrics" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10249
  to_port                  = 10249
  source_security_group_id = aws_security_group.worker.id
}

# Allow apiserver to access kubelets for exec, log, port-forward
resource "aws_security_group_rule" "controller-kubelet" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10250
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "controller-kubelet-self" {
  security_group_id = aws_security_group.controller.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

# Allow Prometheus to scrape kube-scheduler
resource "aws_security_group_rule" "controller-scheduler-metrics" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10259
  to_port                  = 10259
  source_security_group_id = aws_security_group.worker.id
}

# Allow Prometheus to scrape kube-controller-manager
resource "aws_security_group_rule" "controller-manager-metrics" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10257
  to_port                  = 10257
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "controller-egress" {
  security_group_id = aws_security_group.controller.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

# Worker security group

resource "aws_security_group" "worker" {
  name        = "${var.cluster_name}-worker"
  description = "${var.cluster_name} worker security group"

  vpc_id = aws_vpc.network.id

  tags = {
    "Name" = "${var.cluster_name}-worker"
  }
}

resource "aws_security_group_rule" "worker-icmp" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.worker.id

  type                     = "ingress"
  protocol                 = "icmp"
  from_port                = 8
  to_port                  = 0
  source_security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "worker-icmp-self" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.worker.id

  type      = "ingress"
  protocol  = "icmp"
  from_port = 8
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "worker-ssh" {
  security_group_id = aws_security_group.worker.id

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker-http" {
  security_group_id = aws_security_group.worker.id

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker-https" {
  security_group_id = aws_security_group.worker.id

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker-cilium-health" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.worker.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 4240
  to_port                  = 4240
  source_security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "worker-cilium-health-self" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.worker.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 4240
  to_port   = 4240
  self      = true
}

resource "aws_security_group_rule" "worker-cilium-metrics" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.worker.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9962
  to_port                  = 9965
  source_security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "worker-cilium-metrics-self" {
  count = var.networking == "cilium" ? 1 : 0

  security_group_id = aws_security_group.worker.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 9962
  to_port   = 9965
  self      = true
}

# Linux VXLAN default
resource "aws_security_group_rule" "worker-vxlan" {
  security_group_id = aws_security_group.worker.id

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8472
  to_port                  = 8472
  source_security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "worker-vxlan-self" {
  security_group_id = aws_security_group.worker.id

  type      = "ingress"
  protocol  = "udp"
  from_port = 8472
  to_port   = 8472
  self      = true
}

# Allow Prometheus to scrape node-exporter daemonset
resource "aws_security_group_rule" "worker-node-exporter" {
  security_group_id = aws_security_group.worker.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 9100
  to_port   = 9100
  self      = true
}

# Allow Prometheus to scrape kube-proxy
resource "aws_security_group_rule" "worker-kube-proxy" {
  security_group_id = aws_security_group.worker.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10249
  to_port   = 10249
  self      = true
}

# Allow apiserver to access kubelets for exec, log, port-forward
resource "aws_security_group_rule" "worker-kubelet" {
  security_group_id = aws_security_group.worker.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10250
  source_security_group_id = aws_security_group.controller.id
}

# Allow Prometheus to scrape kubelet metrics
resource "aws_security_group_rule" "worker-kubelet-self" {
  security_group_id = aws_security_group.worker.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

resource "aws_security_group_rule" "ingress-health" {
  security_group_id = aws_security_group.worker.id

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 10254
  to_port     = 10254
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker-egress" {
  security_group_id = aws_security_group.worker.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

