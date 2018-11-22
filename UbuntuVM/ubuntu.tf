# Configure the Microsoft Azure Provider
provider "azurerm" {}

# Create a resource group (if it doesn’t exist)
resource "azurerm_resource_group" "group" {
  name     = "${var.resource_group_name}"
  location = "${azurerm_resource_group.group.location}"
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "test-vnet"
  address_space       = ["192.168.99.0/24"]
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "test-subnet"
  resource_group_name  = "${azurerm_resource_group.group.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "192.168.99.0/25"
}

# # Create NSG
# resource "azurerm_network_security_group" "nsg" {}

# Create public IPs
resource "azurerm_public_ip" "ip" {
  name                         = "test-ip"
  location                     = "${azurerm_resource_group.group.location}"
  resource_group_name          = "${azurerm_resource_group.group.name}"
  public_ip_address_allocation = "static"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "test-nic"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = "${azurerm_public_ip.ip.id}"
  }
}

# create storage account
resource "azurerm_managed_disk" "vmdisk" {
  name                 = "testdisk666"
  resource_group_name  = "${azurerm_resource_group.group.name}"
  location             = "${azurerm_resource_group.group.location}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "30"
}

# create virtual machine

# az vm image list-publishers -l westeurope --query [].name -o tsv
# az vm image list-offers -l westeurope -p Canonical --query [].name -o tsv
# az vm image list-skus -l westeurope -p Canonical -f UbuntuServer --query [].name -o tsv
# az vm image list --all -p Canonical -f UbuntuServer -s 18.04-DAILY-LTS -l westeurope --query [].urn -o tsv

resource "azurerm_virtual_machine" "vm" {
  name                  = "terraformvm"
  location              = "${azurerm_resource_group.group.location}"
  resource_group_name   = "${azurerm_resource_group.group.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.vmdisk.name}"
    managed_disk_id = "${azurerm_managed_disk.vmdisk.name}"
    create_option   = "Attach"
    lun             = "1"
    disk_size_gb    = "${azurerm_managed_disk.vmdisk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "ubuntu"
    admin_username = "nenad"
    admin_password = "${var.os_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "test"
  }
}
