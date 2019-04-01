output "storage_account_key" {
  value = "${azurerm_storage_account.storage.primary_access_key}"
}