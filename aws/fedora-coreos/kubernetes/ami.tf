
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

# Experimental Fedora CoreOS arm64 / aarch64 AMIs from Poseidon
# WARNING: These AMIs will be removed when Fedora CoreOS publishes arm64 AMIs
# and may be removed for any reason before then as well. Do not use.
data "aws_ami" "fedora-coreos-arm" {
  most_recent = true
  owners      = ["099663496933"]

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
    values = ["fedora-coreos-*"]
  }
}

