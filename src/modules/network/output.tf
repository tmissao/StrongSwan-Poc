output subnet {
  value = var.subnet_addresses
}

output vm {
  value = {
    "public_ip" = var.bridge_vm_public_ip
    "private_ip" = azurerm_network_interface.vm.private_ip_address
  }
}