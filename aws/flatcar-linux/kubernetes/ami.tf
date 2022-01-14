locals {
  # Pick a Flatcar Linux AMI
  # flatcar-stable -> Flatcar Linux AMI
  ami_id  = var.arch == "arm64" ? data.aws_ami.flatcar-arm64[0].image_id : data.aws_ami.flatcar.image_id
  channel = split("-", var.os_image)[1]
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
    values = ["Flatcar-${local.channel}-*"]
  }
}

data "aws_ami" "flatcar-arm64" {
  count = var.arch == "arm64" ? 1 : 0

  most_recent = true
  owners      = ["075585003325"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-${local.channel}-*"]
  }
}

