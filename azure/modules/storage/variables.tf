variable "location" {
  type        = "string"
  default     = "westus"
  description = "resource location"
}

variable "name_prefix" {
  type        = "string"
  description = "resource name prefix"
}

variable "resource_group_name" {
  type        = "string"
  description = "resource group name"
}

variable "account_tier" {
  type        = "string"
  default     = "Standard"
  description = "Storage account tier[Standard, Premier]"
}

variable "account_replication_type" {
  type        = "string"
  default     = "LRS"
  description = "Storage account replication type[LRS, GRS, RAGRS, ZRS]"
}
