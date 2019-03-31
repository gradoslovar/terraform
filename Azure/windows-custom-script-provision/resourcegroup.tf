# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~>1.6"
}

# terraform {
#     backend "azurerm" {}
# }

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = "${var.location}"
}