
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

  // pin on known ok versions as preview matures
  filter {
    name   = "name"
    values = ["fedora-coreos-30.20190716.1-hvm"]
  }
}
