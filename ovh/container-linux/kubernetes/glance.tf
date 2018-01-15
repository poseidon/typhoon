# AUTOMATICALLY LOOK UP THE LATEST PRE-BUILT GLANCE IMAGE
#
# NOTE: This Terraform data source must return at least one Image result or the entire template will fail.
data "openstack_images_image_v2" "coreos" {
  count       = "${var.image_id == "" ? 1 : 0}"
  name        = "${lookup(var.image_names, var.region)}"
  most_recent = true
}
