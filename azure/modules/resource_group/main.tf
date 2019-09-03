locals {
  resource_group_name = "${var.name_prefix}-rg"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_group_name}"
  location = "${var.location}"
}
