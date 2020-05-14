
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
