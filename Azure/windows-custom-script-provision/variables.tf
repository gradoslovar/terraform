variable "prefix" {}

variable location {}

variable "environment" {
  default = "test"
}

variable "file_share_name" {
  default = "fileshare"
}

variable "vm_admin_username" {
  default = "nenad"
}

variable "vm_admin_password" {}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "vnet_address_prefix" {
  default = "10.200.200.0/24"
}

variable "subnet_address_prefix" {
  default = "10.200.200.0/27"
}

variable "storage_account_name" {}

variable "storage_account_key" {}




