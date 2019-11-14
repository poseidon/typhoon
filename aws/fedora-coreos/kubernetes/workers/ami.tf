
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
    name   = "name"
    values = ["fedora-coreos-30.*.*-hvm"]
  }

  # try to filter out dev images (AWS filters can't)
  name_regex = "^fedora-coreos-30.[0-9]*.[0-9]*-hvm*"
}
