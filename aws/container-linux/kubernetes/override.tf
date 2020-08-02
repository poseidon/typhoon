// usage az-zone-match = ["*az1"]
variable "az-zone-match" {
  default = ["*"]
}

data "aws_availability_zones" "all" {
  filter {
    name = "zone-id"
    values = var.az-zone-match
  }
}
