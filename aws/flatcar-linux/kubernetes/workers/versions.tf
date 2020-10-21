# Terraform version and plugin versions

terraform {
  required_version = ">= 0.12.26, < 0.14.0"
  required_providers {
    aws      = ">= 2.23, <= 4.0"
    template = "~> 2.1"

    ct = {
      source  = "poseidon/ct"
      version = "~> 0.6.1"
    }
  }
}
