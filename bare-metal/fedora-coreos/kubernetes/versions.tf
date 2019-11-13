# Terraform version and plugin versions

terraform {
  required_version = "~> 0.12.6"
  required_providers {
    matchbox = "~> 0.3.0"
    ct       = "~> 0.4"
    template = "~> 2.1"
    null     = "~> 2.1"
  }
}
