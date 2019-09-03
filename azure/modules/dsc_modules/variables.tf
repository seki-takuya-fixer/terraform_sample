variable "storage_account_name" {
  type        = "string"
  description = "Blob storage account to place dsc modules file"
}

variable "resource_group_name" {
  type        = "string"
  description = "Blob storage account resource group to place dsc modules file"
}

variable "container_name" {
  type        = "string"
  default     = "dsc"
  description = "Container to place dsc modules file"
}
