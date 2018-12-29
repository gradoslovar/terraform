# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~>1.6"
}
# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "demo-rg" {
    name     = "${var.prefix}"
    location = "${var.location}"
}

# Create virtual network
resource "azurerm_virtual_network" "demo-vnet" {
  name                = "${var.prefix}-vnet"
  location            = "${azurerm_resource_group.demo-rg.location}"
  resource_group_name = "${azurerm_resource_group.demo-rg.name}"
  address_space = ["192.168.255.0/24"]
}

# Create vnet subnet
resource "azurerm_subnet" "demo-subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = "${azurerm_resource_group.demo-rg.name}"
  address_prefix       = "192.168.255.0/25"
  virtual_network_name = "${azurerm_virtual_network.demo-vnet.name}"
  network_security_group_id = "${azurerm_network_security_group.demo-nsg.id}"
  service_endpoints    = ["Microsoft.Storage", "Microsoft.Sql"]
}

# Create NSG
resource "azurerm_network_security_group" "demo-nsg" {
  name                = "${var.prefix}-nsg"  
  location            = "${azurerm_resource_group.demo-rg.location}"  
  resource_group_name = "${azurerm_resource_group.demo-rg.name}"

  security_rule {  //Here opened RDP port
      name                       = "RDP"  
      priority                   = 1001  
      direction                  = "Inbound"  
      access                     = "Allow"  
      protocol                   = "Tcp"  
      source_port_range          = "*"  
      destination_port_range     = "3389"  
      source_address_prefix      = "*"  
      destination_address_prefix = "*"  
  }
}

# Create NSG association
# Note: NSG associations currently need to be configured on both this resource
#       and using the network_security_group_id field on the azurerm_subnet resource.
#       The next major version of the AzureRM Provider (2.0) will remove the network_security_group_id
#       field from the azurerm_subnet resource such that this resource is used to link resources in future.
resource "azurerm_subnet_network_security_group_association" "demo-association" {
  subnet_id                 = "${azurerm_subnet.demo-subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.demo-nsg.id}"
}

# Create Network Interface
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.demo-rg.location}"
  resource_group_name = "${azurerm_resource_group.demo-rg.name}"

  ip_configuration {
    name                          = "demoConfiguration"
    subnet_id                     = "${azurerm_subnet.demo-subnet.id}"
    private_ip_address_allocation = "static"
  }
}


