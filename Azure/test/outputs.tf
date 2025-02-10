output "vnet_name" {
  description = "The name of the virtual network"
  value = azurerm_virtual_network.vnet.name
}

output "vnet_config_id" {
  description = "The virtual NetworkConfiguration ID"
  value = azurerm_virtual_network.vnet.id
}

output "vnet_guid" {
  description = "The GUID of the virtual network"
  value = azurerm_virtual_network.vnet.guid
}

output "subnet_id" {
  description = "One or more subnet blocks, if defined"
  value = azurerm_subnet.subnet.id
}