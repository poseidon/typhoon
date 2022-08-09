locals {
  ami_id = var.arch == "arm64" ? data.aws_ami.fedora-coreos-arm[0].image_id : data.aws_ami.fedora-coreos.image_id
}

data "aws_ami" "fedora-coreos" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "description"
    values = ["Fedora CoreOS ${var.os_stream} *"]
  }
}

data "aws_ami" "fedora-coreos-arm" {
  count = var.arch == "arm64" ? 1 : 0

  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "description"
    values = ["Fedora CoreOS ${var.os_stream} *"]
  }
}
