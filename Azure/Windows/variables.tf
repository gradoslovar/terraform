variable client_id {}
variable client_secret {}

variable resource_group_name {
    default = "demo"
}

variable location {
    default = "West Europe"
}

variable "vm_size" {
    default = "Standard_DS2_v2"
}

variable "vnet_name" {
  default = "demo-vnet"
}

variable "subnet_name" {
  default = "demo-subnet"
}
variable "nsg_name" {
  default = "demo-nsg"
}
