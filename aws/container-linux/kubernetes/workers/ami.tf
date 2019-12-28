locals {
  # Pick a CoreOS Container Linux derivative
  # coreos-stable -> Container Linux AMI
  # flatcar-stable -> Flatcar Linux AMI
  ami_id = local.flavor == "flatcar" ? data.aws_ami.flatcar.image_id : data.aws_ami.coreos.image_id

  flavor  = split("-", var.os_image)[0]
  channel = split("-", var.os_image)[1]
}

data "aws_ami" "coreos" {
  most_recent = true
  owners      = ["595879546273"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["CoreOS-${local.flavor == "coreos" ? local.channel : "stable"}-*"]
  }
}

data "aws_ami" "flatcar" {
  most_recent = true
  owners      = ["075585003325"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-${local.flavor == "flatcar" ? local.channel : "stable"}-*"]
  }
}

