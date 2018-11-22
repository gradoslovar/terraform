data "azurerm_public_ip" "pip" {
  name                = "${azurerm_public_ip.pip.name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
}

output "pip" {
  value = "${data.azurerm_public_ip.pip.ip_address}"
}

output "ssh_command" {
  value = "ssh nenad@${data.azurerm_public_ip.pip.ip_address}"
}