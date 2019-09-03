provider "azurerm" {
  version         = "=1.29.0"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

module "resource_group" {
  source      = "../../modules/resource_group"
  name_prefix = "${var.name_prefix}"
  location    = "${var.location}"
}

module "storage_account" {
  source              = "../../modules/storage"
  name_prefix         = "${var.name_prefix}"
  location            = "${var.location}"
  resource_group_name = "${module.resource_group.name}"
}

module "dsc_modules" {
  source               = "../../modules/dsc_modules"
  storage_account_name = "${module.storage_account.name}"
  resource_group_name  = "${module.resource_group.name}"
}
