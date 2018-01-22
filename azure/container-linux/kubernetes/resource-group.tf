resource "azurerm_resource_group" "rg" {
  name     = "${var.cluster_name}-rg"
  location = "${var.location}"

  tags {
    cluster_name = "${var.cluster_name}"
  }
}
