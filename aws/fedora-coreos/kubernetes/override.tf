// usage az-zone-match = ["*az1"]
variable "az-zone-match" {
  default = ["eu-west-1a"]
}

variable "subnet_size" {
  default = 2
}

data "aws_availability_zones" "all" {
  filter {
    name = "zone-name"
    values = var.az-zone-match
  }
}

resource "aws_subnet" "public" {
  // Increase number of IPV4 to fix Calico IP-Pool exhaust issue
  count = var.subnet_size
  availability_zone = data.aws_availability_zones.all.names[0]
  cidr_block        = cidrsubnet(var.host_cidr, 2, count.index)
}

# Network Load Balancer for apiservers and ingress
resource "aws_lb" "nlb" {
  subnets = null
  subnet_mapping {
    subnet_id = aws_subnet.public.0.id
    allocation_id = var.nlb_eip_id[0]
  }
//  subnets = [aws_subnet.public.0.id]
}

