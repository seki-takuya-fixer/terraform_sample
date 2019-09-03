output "blob_url" {
  depends_on = ["azurerm_storage_blob.main"]
  value      = "${azurerm_storage_blob.main.url}"
}

output "sas_url_query_string" {
  depends_on = ["azurerm_storage_blob.main"]
  value      = "${module.sas.sas_url_query_string}"
}
