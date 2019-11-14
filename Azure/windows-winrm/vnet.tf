# Create virtual network for AD Zone
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["${var.vnet_address_prefix}"]

  tags {
    env = "Test"
  }
}

# Create vnet subnet for AD
resource "azurerm_subnet" "subnet" {
  name                      = "${var.prefix}-subnet"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  address_prefix            = "${var.subnet_address_prefix}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  network_security_group_id = "${azurerm_network_security_group.domain-nsg.id}"
}

# Create NSG
resource "azurerm_network_security_group" "domain-nsg" {
  name                = "${var.prefix}-domain-nsg"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "Alsid_RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.alsid_vpn_address}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${var.prefix}-RDP"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.whitelist_addresses}"
    destination_address_prefix = "*"
  }

  tags {
    env = "Test"
  }
}

# Create NSG association
# Note: NSG associations currently need to be configured on both this resource
#       and using the network_security_group_id field on the azurerm_subnet resource.
#       The next major version of the AzureRM Provider (2.0) will remove the network_security_group_id
#       field from the azurerm_subnet resource such that this resource is used to link resources in future.
resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = "${azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.domain-nsg.id}"
}
