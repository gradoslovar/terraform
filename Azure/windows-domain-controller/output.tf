output "public_ip" {
  value = "${azurerm_public_ip.vm-ip.ip_address}"
}

