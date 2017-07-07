# Define variables for the AzureRM provider

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

# Define number of VM instances
variable "azurerm_instances" {
  type    = "string"
  default = "3"
}

# Azure reousces variables
variable "azurerm_location" {
  type    = "string"
  default = "West Europe"
}

variable "azurerm_vm_admin_password" {
  description = "Admin password for Azure VMs"
}

# variable "address_space" {
#   description = "Addres space for Azure VM network"
#   default = "192.168.2.0/24"
# }