# Terraform version and plugin versions

terraform {
  required_version = "~> 0.12.6"
  required_providers {
    google   = ">= 2.19, < 4.0"
    ct       = "~> 0.3"
    template = "~> 2.1"
    null     = "~> 2.1"
  }
}
