# Terraform version and plugin versions

terraform {
  required_version = ">= 0.13.0, < 2.0.0"
  required_providers {
    aws = ">= 2.23, <= 5.0"
    ct = {
      source  = "poseidon/ct"
      version = "~> 0.9"
    }
  }
}
