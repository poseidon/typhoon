data "aws_availability_zones" "all" {}

# Network VPC, gateway, and routes

resource "aws_vpc" "network" {
  count                            = "${local.manage_vpc}"
  cidr_block                       = "${var.host_cidr}"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true

  tags = "${map("Name", "${var.cluster_name}")}"
}

resource "aws_internet_gateway" "gateway" {
  count = "${local.manage_vpc}"

  vpc_id = "${local.manage_vpc ? join("", aws_vpc.network.*.id) : var.vpc_id}"

  tags = "${map("Name", "${var.cluster_name}")}"
}

resource "aws_route_table" "default" {
  count = "${local.manage_vpc}"

  vpc_id = "${local.manage_vpc ? join("", aws_vpc.network.*.id) : var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.gateway.id}"
  }

  tags = "${map("Name", "${var.cluster_name}")}"
}

# Subnets (one per availability zone)

resource "aws_subnet" "public" {
  count = "${length(data.aws_availability_zones.all.names) * local.manage_vpc}"

  vpc_id            = "${local.manage_vpc ? join("", aws_vpc.network.*.id) : var.vpc_id}"
  availability_zone = "${data.aws_availability_zones.all.names[count.index]}"

  cidr_block                      = "${cidrsubnet(var.host_cidr, 4, count.index)}"
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.network.ipv6_cidr_block, 8, count.index)}"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  tags = "${map("Name", "${var.cluster_name}-public-${count.index}")}"
}

resource "aws_route_table_association" "public" {
  count = "${length(data.aws_availability_zones.all.names) * local.manage_vpc}"

  route_table_id = "${aws_route_table.default.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}
