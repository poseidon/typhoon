// usage az-zone-match = ["*az1"]
variable "az-zone-match" {
  default = ["eu-west-1a"]
}

variable "subnet_size" {
  default = 2
}

variable "nlb_eip_id" {
  default = null
}

output "controller_security_groups" {
  value       = [aws_security_group.controller.id]
  description = "List of worker security group IDs"
}

output "controller_instance_id" {
  value = aws_instance.controllers.*.id
}