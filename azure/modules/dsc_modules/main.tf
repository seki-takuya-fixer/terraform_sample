locals {
  tmp_dir     = "./tmp/dsc"
  output_path = "dsc_modules.zip"
  files       = ["${path.module}/scripts/DscScript.ps1", "${path.module}/scripts/settings.json"]
}

resource "null_resource" "copy_modules" {
  triggers = {
    // Run always
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOF
if(Test-Path -Path "${local.tmp_dir}"){
  Remove-Item -Path "${local.tmp_dir}" -Recurse -Force
}
New-Item "${local.tmp_dir}" -ItemType Directory
$files = "${join(",",local.files)}" -split ","
$files | ForEach-Object {
  Copy-Item -Path $_ -Destination "${local.tmp_dir}"
}
EOF

    interpreter = ["PowerShell", "-Command"]
  }
}

data "archive_file" "main" {
  depends_on = ["null_resource.copy_modules"]
  type       = "zip"

  source_dir  = "${local.tmp_dir}"
  output_path = "${local.output_path}"
}

data "azurerm_storage_account" "main" {
  name                = "${var.storage_account_name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_storage_container" "main" {
  storage_account_name  = "${data.azurerm_storage_account.main.name}"
  resource_group_name   = "${data.azurerm_storage_account.main.resource_group_name}"
  container_access_type = "blob"
  name                  = "${var.container_name}"
}

resource "azurerm_storage_blob" "main" {
  depends_on             = ["azurerm_storage_container.main", "data.archive_file.main"]
  name                   = "${timestamp() == "" ? local.output_path : local.output_path}" # force delete & insert blob
  resource_group_name    = "${data.azurerm_storage_account.main.resource_group_name}"
  storage_account_name   = "${data.azurerm_storage_account.main.name}"
  storage_container_name = "${azurerm_storage_container.main.name}"
  type                   = "block"
  source                 = "${local.output_path}"
}

module "sas" {
  source               = "../storage_sas"
  storage_account_name = "${data.azurerm_storage_account.main.name}"
  resource_group_name  = "${data.azurerm_storage_account.main.resource_group_name}"
}
