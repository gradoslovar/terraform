# Create VM
resource "azurerm_virtual_machine" "demo-vm" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.demo-rg.location}"
  resource_group_name   = "${azurerm_resource_group.demo-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.demo-nic.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "demo-machine"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
  os_profile_windows_config {
    timezone = "Romance Standard Time"
  }
}