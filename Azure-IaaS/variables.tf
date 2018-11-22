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

variable "azurerm_resource_group" {
  description = "Name of resource group"
}

variable "azurerm_resource_tag" {
  description = "Name of resource group"
  type        = "string"
  default     = "test"
}

variable "azurerm_location" {
  description = "Resource location"
  type = "string"
  default = "West Europe"
}

variable "azurerm_instances" {
  type    = "string"
  default = "1"
}

variable "vnet_name" {
  type    = "string"
  default = "1"
}
variable "vnet_address_space" {
  description = "Addres space for Azure VM network"
  default = "192.168.2.0/24"
}

variable "vnet_subnet_name" {
  type    = "string"
  default = "default"
}
variable "vnet_subnet_address_space" {
  description = "Addres space for Azure VM subnet"
  default = "192.168.2.0/25"
}

variable "azurerm_vm_admin_password" {
  description = "Admin password for Azure VMs"
}