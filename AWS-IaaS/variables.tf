variable "access_key" {
  description = "The AWS access key"
}

variable "secret_key" {
  description = "The AWS secret key"
}

variable "region" {
  description = "The AWS Region"
  default     = "us-east-1"
}

variable "key_name" {
  description = "The key pair to use for AWS resources"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "ami" {
  type        = "map"
  description = "A map of AMIs"
  default     = {}
}

variable "ip_set" {
  description = "Set of IPs to use for our instances"
  default     = ["192.168.1.11", "192.168.1.12"]
}

# variable "ami" {
#     type = "map"
#     default = {
#         us-east-1 = "ami-0d729a60"
#         us-west-1 = "ami-7c4b331c"
#     }
#     description = "List of the AMIs to use"
# }

