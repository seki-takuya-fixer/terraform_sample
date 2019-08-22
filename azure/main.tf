provider "azurerm" {
  version         = "=1.29.0"
  subscription_id = "${var.subscriotion_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}
