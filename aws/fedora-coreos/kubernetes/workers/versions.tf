
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws      = ">= 2.23, <= 4.0"
    ct       = "~> 0.4"
    template = "~> 2.1"
  }
}
