data "aws_availability_zones" "all" {
}

# Network VPC, gateway, and routes

resource "aws_vpc" "network" {
  cidr_block                       = var.host_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true

  tags = {
    "Name" = var.cluster_name
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.network.id

  tags = {
    "Name" = var.cluster_name
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.network.id

  tags = {
    "Name" = var.cluster_name
  }
}

resource "aws_route" "egress-ipv4" {
  route_table_id         = aws_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route" "egress-ipv6" {
  route_table_id              = aws_route_table.default.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.gateway.id
}

# Subnets (one per availability zone)

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.all.names)

  tags = {
    "Name" = "${var.cluster_name}-public-${count.index}"
  }
  vpc_id            = aws_vpc.network.id
  availability_zone = data.aws_availability_zones.all.names[count.index]

  # IPv4 and IPv6 CIDR blocks
  cidr_block      = cidrsubnet(var.host_cidr, 4, count.index)
  ipv6_cidr_block = cidrsubnet(aws_vpc.network.ipv6_cidr_block, 8, count.index)

  # Assign IPv4 and IPv6 addresses to instances
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  # Hostnames assigned to instances
  # resource-name: <ec2-instance-id>.region.compute.internal
  private_dns_hostname_type_on_launch            = "resource-name"
  enable_resource_name_dns_a_record_on_launch    = true
  enable_resource_name_dns_aaaa_record_on_launch = true
}

resource "aws_route_table_association" "public" {
  count = length(data.aws_availability_zones.all.names)

  route_table_id = aws_route_table.default.id
  subnet_id      = aws_subnet.public.*.id[count.index]
}

