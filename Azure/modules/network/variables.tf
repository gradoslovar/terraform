variable "resource_group_name" {
  description = "Resource group name that the Vnet will be created in."
}

variable "location" {
  description = "Azure region where Vnet will be deployed."
}

variable "vnet_name" {
  description = "Name of the Vnet to create"
}

variable "address_space" {
  description = "Vnet address space."
}

variable "subnet_prefixes" {
  description = "List of Vnet subnet addres spaces."
}

variable "subnet_names" {
  description = "List of Vnet subnet names."
}

variable "tags" {
  description = "The tags to associate with Vnet and subnets."
  type = map(string)
}