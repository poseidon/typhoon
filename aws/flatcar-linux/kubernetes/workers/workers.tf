# Workers AutoScaling Group
resource "aws_autoscaling_group" "workers" {
  name = "${var.name}-worker"

  # count
  desired_capacity = var.worker_count
  min_size         = var.worker_count
  max_size         = var.worker_count + 2

  # network
  vpc_zone_identifier = var.subnet_ids

  # instance template
  launch_template {
    id      = aws_launch_template.worker.id
    version = aws_launch_template.worker.latest_version
  }

  # target groups to which instances should be added
  target_group_arns = flatten([
    aws_lb_target_group.workers-http.id,
    aws_lb_target_group.workers-https.id,
    var.target_groups,
  ])

  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup        = 120
      min_healthy_percentage = 90
    }
  }
  # Grace period before checking new instance's health
  health_check_grace_period = 30
  # Cooldown period between scaling activities
  default_cooldown = 30

  lifecycle {
    # override the default destroy and replace update behavior
    create_before_destroy = true
  }

  # Waiting for instance creation delays adding the ASG to state. If instances
  # can't be created (e.g. spot price too low), the ASG will be orphaned.
  # Orphaned ASGs escape cleanup, can't be updated, and keep bidding if spot is
  # used. Disable wait to avoid issues and align with other clouds.
  wait_for_capacity_timeout = "0"

  tag {
    key                 = "Name"
    value               = "${var.name}-worker"
    propagate_at_launch = true
  }
}

# Worker template
resource "aws_launch_template" "worker" {
  name_prefix   = "${var.name}-worker"
  image_id      = local.ami_id
  instance_type = var.instance_type

  # storage
  ebs_optimized = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = var.disk_type
      volume_size           = var.disk_size
      iops                  = var.disk_iops
      encrypted             = true
      delete_on_termination = true
    }
  }

  # network
  network_interfaces {
    associate_public_ip_address = var.associate_public_ipv4_address
    security_groups             = var.security_groups
  }

  # boot
  user_data = sensitive(base64encode(data.ct_config.worker.rendered))

  # metadata
  metadata_options {
    http_tokens = "optional"
  }
  monitoring {
    enabled = false
  }

  # cost
  credit_specification {
    cpu_credits = var.cpu_credits
  }
  dynamic "instance_market_options" {
    for_each = var.spot_price > 0 ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price = var.spot_price
      }
    }
  }

  lifecycle {
    // Override the default destroy and replace update behavior
    create_before_destroy = true
    ignore_changes        = [image_id]
  }
}

# Flatcar Linux worker
data "ct_config" "worker" {
  content = templatefile("${path.module}/butane/worker.yaml", {
    kubeconfig             = indent(10, var.kubeconfig)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    node_labels            = join(",", var.node_labels)
    node_taints            = join(",", var.node_taints)
  })
  strict   = true
  snippets = var.snippets
}
