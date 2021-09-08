resource "azurerm_resource_group" "rg" {
  name = var.project_name
  location = var.location
}

resource "azurerm_public_ip" "network1" {
  name = "strongswan-vnet-1"
  location =  azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
}

resource "azurerm_public_ip" "network2" {
  name = "strongswan-vnet-2"
  location =  azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
}

module network1 {
  source = "./network"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name = "vnet1"
  vnet_addresses = ["30.30.0.0/16"]
  subnet_addresses = ["30.30.1.0/24"]
  bridge_vm_private_ip = "30.30.1.100"
  bridge_vm_public_ip_id = azurerm_public_ip.network1.id
  bridge_vm_public_ip = azurerm_public_ip.network1.ip_address
  strongswan_right_subnet = "31.31.1.0/24"
  strongswan_right_public_ip = azurerm_public_ip.network2.ip_address
  strongswan_password = var.strongswan_password
  vnet_location = azurerm_resource_group.rg.location
}

module network2 {
  source = "./network"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name = "vnet2"
  vnet_addresses = ["31.31.0.0/16"]
  subnet_addresses = ["31.31.1.0/24"]
  bridge_vm_private_ip = "31.31.1.100"
  bridge_vm_public_ip_id = azurerm_public_ip.network2.id
  bridge_vm_public_ip = azurerm_public_ip.network2.ip_address
  strongswan_right_subnet = "30.30.1.0/24"
  strongswan_right_public_ip = azurerm_public_ip.network1.ip_address
  strongswan_password = var.strongswan_password
  vnet_location = azurerm_resource_group.rg.location
}