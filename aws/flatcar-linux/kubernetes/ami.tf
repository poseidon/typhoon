locals {
  # Pick a Flatcar Linux AMI
  # flatcar-stable -> Flatcar Linux AMI
  ami_id  = data.aws_ami.flatcar.image_id
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

