resource "azurerm_resource_group" "network" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  address_space       = ["${var.address_space}"]
  resource_group_name = azurerm_resource_group.network.name
  tags                 = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet_prefixes[count.index]
  count                = length(var.subnet_names)
}