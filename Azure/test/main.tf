terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.88.1"
    }
  }
  #  backend "azurerm" {}

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-afad-domain-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["${var.vnet_address_prefix}"]
}

# Create vnet subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-server-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefix       = var.subnet_prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
}