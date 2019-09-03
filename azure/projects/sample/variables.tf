variable "tenant_id" {
  type        = "string"
  description = "Azure AD Tenant Id"
}

variable "subscription_id" {
  type        = "string"
  description = "Azure Subscription Id"
}

variable "client_id" {
  type        = "string"
  description = "Azure ServicePrincipal Application Id"
}

variable "client_secret" {
  type        = "string"
  description = "Azure ServicePrincipal Client Secret"
}

variable "name_prefix" {
  type        = "string"
  default     = "sample"
  description = "Resource Name Prefix"
}

variable "location" {
  type        = "string"
  default     = "westus"
  description = "Resource Location"
}
