# Configure the Microsoft Azure Provider
provider "azurerm" {}

# Create a resource group (if it doesn’t exist)
resource "azurerm_resource_group" "group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
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

# Create NSG
resource "azurerm_network_security_group" "nsg" {
  name = "test-nsg"
  location = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1022
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create NSG association
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = "${azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

# Create public IPs
resource "azurerm_public_ip" "pip" {
  name                         = "${var.hostname}-pip"
  location                     = "${azurerm_resource_group.group.location}"
  resource_group_name          = "${azurerm_resource_group.group.name}"
  public_ip_address_allocation = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "test-nic"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}

# # create storage account
# resource "azurerm_managed_disk" "vmdisk" {
#   name                 = "testdisk666"
#   resource_group_name  = "${azurerm_resource_group.group.name}"
#   location             = "${azurerm_resource_group.group.location}"
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "30"
# }

# create virtual machine

# az vm image list-publishers -l westeurope --query [].name -o tsv
# az vm image list-offers -l westeurope -p Canonical --query [].name -o tsv
# az vm image list-skus -l westeurope -p Canonical -f UbuntuServer --query [].name -o tsv
# az vm image list --all -p Canonical -f UbuntuServer -s 18.04-DAILY-LTS -l westeurope --query [].urn -o tsv

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.hostname}"
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

  storage_os_disk {
    name              = "${var.hostname}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.hostname}"
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