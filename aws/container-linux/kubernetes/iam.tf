# IAM Roles and Policies for Controllers (Masters) and Workers (Nodes)

## Controllers / Masters
data "aws_iam_policy_document" "controller_role_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "controller_role" {
  name               = "${var.cluster_name}-controller-instance-role"
  assume_role_policy = "${data.aws_iam_policy_document.controller_role_doc.json}"
}

# Permission borrowed from https://github.com/kubernetes/kops/issues/1873
data "aws_iam_policy_document" "controller_policy_doc" {
  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:CreateRoute",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteRoute",
      "ec2:DeleteVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:ModifyInstanceAttribute",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = [ "*" ]
  }
}

resource "aws_iam_role_policy" "controller_policy" {
  name        = "${var.cluster_name}-controller-instance-role-policy"
  # path        = "/"
  role = "${aws_iam_role.controller_role.id}"
  policy = "${data.aws_iam_policy_document.controller_policy_doc.json}"
}

resource "aws_iam_instance_profile" "controller_profile" {
  name  = "${var.cluster_name}-controller-instance-role"
  role = "${aws_iam_role.controller_role.name}"
}

## Workers / Nodes
data "aws_iam_policy_document" "worker_role_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker_role" {
  name               = "${var.cluster_name}-worker-instance-role"
  assume_role_policy = "${data.aws_iam_policy_document.worker_role_doc.json}"
}

# Permission borrowed from https://github.com/kubernetes/kops/issues/1873
data "aws_iam_policy_document" "worker_policy_doc" {
  statement {
    actions = ["ec2:DescribeInstances"]
    resources = [ "*" ]
  }
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "worker_policy" {
  name        = "${var.cluster_name}-worker-instance-role-policy"
  # path        = "/"
  role = "${aws_iam_role.worker_role.id}"
  policy = "${data.aws_iam_policy_document.worker_policy_doc.json}"
}

resource "aws_iam_instance_profile" "worker_profile" {
  name  = "${var.cluster_name}-worker-instance-role"
  role = "${aws_iam_role.worker_role.name}"
}