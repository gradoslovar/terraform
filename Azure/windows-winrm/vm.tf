locals {
  #virtual_machine_name = "${var.prefix}-dc-vm"
  # virtual_machine_fqdn = "${local.virtual_machine_name}.${var.active_directory_domain}"
  # custom_data_params   = "Param($RemoteHostName = \"${local.virtual_machine_fqdn}\", $ComputerName = \"${local.virtual_machine_name}\")"
  # custom_data_content  = "${local.custom_data_params} ${file("${path.module}/scripts/winrm.ps1")}"
  custom_data_content = "${file("${path.module}/scripts/Set-LabVm.ps1")}"
}

# Create Public IP Address
resource "azurerm_public_ip" "vm-ip" {
  name                = "${var.prefix}-vm-ip"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Static"

  tags {
    env = "Test"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "vm-nic" {
  name                = "${var.prefix}-vm-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "dc-ip-configuration"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vm-ip.id}"
  }

  tags {
    env = "Test"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                          = "${var.prefix}-vm"
  location                      = "${azurerm_resource_group.rg.location}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  network_interface_ids         = ["${azurerm_network_interface.vm-nic.id}"]
  vm_size                       = "${var.dc_vm_size}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-vm-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "machine"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
    custom_data    = "${local.custom_data_content}"
  }

  boot_diagnostics {
    enabled = true
    storage_uri = "${azurerm_storage_account.dlstorage.primary_blob_endpoint}"
  }

  # winrm {
  #   protocol = "HTTP"
  # }

  os_profile_windows_config {
    provision_vm_agent        = true
    timezone                  = "Romance Standard Time"

    # additional_unattend_config {
    #   pass         = "oobeSystem"
    #   component    = "Microsoft-Windows-Shell-Setup"
    #   setting_name = "AutoLogon"
    #   content      = "<AutoLogon><Password><Value>${var.vm_admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.vm_admin_username}</Username></AutoLogon>"
    # }

    # additional_unattend_config {
    #   pass         = "oobeSystem"
    #   component    = "Microsoft-Windows-Shell-Setup"
    #   setting_name = "FirstLogonCommands"
    #   content      = "${file("scripts/FirstLogonCommands.xml")}"
    # }
  }
}

resource "azurerm_virtual_machine_extension" "setup" {
  name                       = "testSetup"
  resource_group_name        = "${azurerm_resource_group.rg.name}"
  location                   = "${azurerm_resource_group.rg.location}"
  virtual_machine_name       = "${azurerm_virtual_machine.dc-vm.name}"
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
  #count                      = "${var.node_count}"
  depends_on                 = ["azurerm_virtual_machine.vm"]


  settings = <<SETTINGS
{
  "fileUris": ["scripts/Set-LabVm.ps1"]
}
SETTINGS


  protected_settings = <<SETTINGS
 {
   "commandToExecute": "powershell Set-LabVm.ps1"
 }
SETTINGS
}

