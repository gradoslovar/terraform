# Declare variables
variable "prefix" {}
variable "location" {}
variable "address_space" {}
variable "subnet_prefixes" {}

# Set Azure provider
provider "azurerm" {
  version = "~>1.40.0"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = var.location
}

# Use the network module to create a vnet and subnet
module "network" {
    source              = "./network"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.location
    vnet_name           = "${var.prefix}-vnet"
    address_space       = var.address_space
    subnet_names        = [
        "${var.prefix}-sen-subnet",
        "${var.prefix}-dl-subnet",
        "${var.prefix}-sql-subnet",
        "GatewaySubnet"
    ]
    subnet_prefixes     = var.subnet_prefixes
    tags                = {
        customer     = var.prefix
    }
}