variable "azurerm_client_id" {
  description = "Client ID"
}

variable "azurerm_client_secret" {
  description = "Client Secret"
}

variable "azurerm_subscription_id" {
  description = "Azure Subscription ID"
}

variable "azurerm_tenant_id" {
  description = "Azure Tenant ID"
}

variable "azurerm_location" {
  type    = "string"
  default = "West Europe"
}