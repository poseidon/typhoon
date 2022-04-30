# Workers AutoScaling Group
resource "aws_autoscaling_group" "workers" {
  name = "${var.name}-worker ${aws_launch_template.worker.name}"

  # count
  desired_capacity          = var.worker_count
  min_size                  = var.worker_count
  max_size                  = var.worker_count + 2
  default_cooldown          = 30
  health_check_grace_period = 30

  # network
  vpc_zone_identifier = var.subnet_ids

  # template
  launch_template {
      id      = aws_launch_template.worker.id
      version = "$Latest"
    }

  # target groups to which instances should be added
  target_group_arns = flatten([
    aws_lb_target_group.workers-http.id,
    aws_lb_target_group.workers-https.id,
    var.target_groups,
  ])

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

resource "aws_launch_template" "worker" {
  image_id          = var.arch == "arm64" ? data.aws_ami.fedora-coreos-arm[0].image_id : data.aws_ami.fedora-coreos.image_id
  instance_type     = var.instance_type

  user_data = base64encode(data.ct_config.worker-ignition.rendered)

  monitoring {
    enabled = false
  }

  dynamic "instance_market_options" {

    for_each = var.spot_price == 0 ? toset([]) : toset([1])

    content {
      market_type = "spot"
      spot_options {
        instance_interruption_behavior = "terminate"
        max_price                      = var.spot_price
        spot_instance_type             = "one-time"
      }
    }
  } 

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = var.disk_type
      volume_size = var.disk_size
      iops        = var.disk_iops
      encrypted   = true
    }
  }

  # network
  vpc_security_group_ids = var.security_groups

  lifecycle {
    // Override the default destroy and replace update behavior
    create_before_destroy = true
    ignore_changes        = [image_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      data.aws_default_tags.current.tags,
    { Name = "${var.name}-worker" })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      data.aws_default_tags.current.tags,
    { Name = "${var.name}-worker" })
  }
}

data "aws_default_tags" "current" {}

# Worker Ignition config
data "ct_config" "worker-ignition" {
  content  = data.template_file.worker-config.rendered
  strict   = true
  snippets = var.snippets
}

# Worker Fedora CoreOS config
data "template_file" "worker-config" {
  template = file("${path.module}/fcc/worker.yaml")

  vars = {
    kubeconfig             = indent(10, var.kubeconfig)
    ssh_authorized_key     = var.ssh_authorized_key
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
    node_labels            = join(",", var.node_labels)
    node_taints            = join(",", var.node_taints)
  }
}

