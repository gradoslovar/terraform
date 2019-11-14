output "public_ip" {
  value = "${azurerm_public_ip.vm-ip.ip_address}"
}

output "file_share_url" {
  value = "${azurerm_storage_share.cetishare.url}"
}

output "storage_account_key" {
  value = "${azurerm_storage_account.dlstorage.primary_access_key}"
}

output "primary_file_host" {
  value = "${azurerm_storage_account.dlstorage.primary_file_host}"
}

output "primary_file_endpoint" {
  value = "${azurerm_storage_account.dlstorage.primary_file_endpoint}"
}


