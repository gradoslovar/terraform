resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}filestorage"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environmnet = "${var.environment}"
  }
}

resource "azurerm_storage_share" "file-share" {
  name = "${var.file_share_name}"

  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_name = "${azurerm_storage_account.storage.name}"
}