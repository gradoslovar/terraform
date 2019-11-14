resource "azurerm_storage_account" "dlstorage" {
  name                     = "${var.prefix}afadstorage"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environmnet = "Test"
  }
}

resource "azurerm_storage_share" "cetishare" {
  name = "ceti-spawner-data"

  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_name = "${azurerm_storage_account.dlstorage.name}"
}