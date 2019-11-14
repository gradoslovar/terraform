# declare variables and defaults
variable "prefix" {}
variable "environment" {}
variable "location" {}
variable "address_space" {}
variable "subnet_names" {}
variable "subnet_prefixes" {}


# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-afad-${var.environment}"
    location = var.location
}

# Use the network module to create a vnet and subnet
module "network" {
    source              = "./modules/network"
    resource_group_name = "${var.prefix}-afad-${var.environment}"
    location            = var.location
    vnet_name           = "${var.prefix}-afad-${var.environment}-vnet"
    address_space       = var.address_space
    subnet_names        = var.subnet_names
    subnet_prefixes     = var.subnet_prefixes
    tags                = {
        environment  = var.environment
        customer     = var.prefix
    }
}