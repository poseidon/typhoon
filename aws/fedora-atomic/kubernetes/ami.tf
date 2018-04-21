data "aws_ami" "fedora" {
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
    values = ["Fedora-Atomic-27-20180419.0.x86_64-*-gp2-*"]
  }
}
