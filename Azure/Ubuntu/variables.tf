variable "client_id" {}

variable "client_secret" {}

variable "resource_group_name" {
  type    = "string"
  default = "test"
}

variable "location" {
  type    = "string"
  default = "westeurope"
}

variable "os_admin_password" {
  type = "string"
}

variable "hostname" {
  type    = "string"
  default = "ubuntu"
}
