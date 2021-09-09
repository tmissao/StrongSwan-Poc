variable "vnet_name" {
  default = "vnet"
}

variable "vnet_addresses" {
  default = ["10.10.0.0/16"]
}

variable "vnet_location" {
  default = "East US"
}

variable "subnet_name" {
  default = "default"
}

variable "subnet_addresses" {
  default = ["10.10.0.0/24"]
}

variable "bridge_vm_private_ip" {
  default = "10.10.0.4"
}

variable "bridge_vm_public_ip_id" {}

variable "bridge_vm_public_ip"{}

variable "resource_group_name" {}

variable "strongswan_setup" {
  default = true
}

variable "strongswan_right_public_ip" {}

variable "strongswan_right_subnet" {}

variable "strongswan_password" {}
