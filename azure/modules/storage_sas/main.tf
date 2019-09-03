data "azurerm_storage_account" "this" {
  name                = "${var.storage_account_name}"
  resource_group_name = "${var.resource_group_name}"
}

data "azurerm_storage_account_sas" "this" {
  connection_string = "${data.azurerm_storage_account.this.primary_connection_string}"
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "${timeadd(timestamp(), "-5m")}"
  expiry = "${timeadd(timestamp(), "87600h")}"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
  }
}
