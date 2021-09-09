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
  source = "../modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name = "vnet1"
  vnet_addresses = ["30.30.0.0/16"]
  subnet_addresses = ["30.30.1.0/24"]
  bridge_vm_private_ip = "30.30.1.100"
  bridge_vm_public_ip_id = azurerm_public_ip.network1.id
  bridge_vm_public_ip = azurerm_public_ip.network1.ip_address
  strongswan_setup = !var.strongswan_ansible_setup
  strongswan_right_subnet = "31.31.1.0/24"
  strongswan_right_public_ip = azurerm_public_ip.network2.ip_address
  strongswan_password = var.strongswan_password
  vnet_location = azurerm_resource_group.rg.location
}

module network2 {
  source = "../modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name = "vnet2"
  vnet_addresses = ["31.31.0.0/16"]
  subnet_addresses = ["31.31.1.0/24"]
  bridge_vm_private_ip = "31.31.1.100"
  bridge_vm_public_ip_id = azurerm_public_ip.network2.id
  bridge_vm_public_ip = azurerm_public_ip.network2.ip_address
  strongswan_setup = !var.strongswan_ansible_setup
  strongswan_right_subnet = "30.30.1.0/24"
  strongswan_right_public_ip = azurerm_public_ip.network1.ip_address
  strongswan_password = var.strongswan_password
  vnet_location = azurerm_resource_group.rg.location
}

resource "local_file" "ansible_hosts" {
  count = var.strongswan_ansible_setup ? 1 : 0
  content = templatefile("./templates/hosts.tpl", { 
    vm1_public_ip = module.network1.vm.public_ip, vm1_private_ip = module.network1.vm.private_ip, 
    vm1_subnet = module.network1.subnet[0],vm2_public_ip = module.network2.vm.public_ip, 
    vm2_private_ip = module.network2.vm.private_ip, vm2_subnet = module.network2.subnet[0]
  })
  filename = "${var.ansible_project_path}/hosts"
  file_permission = 0644
}

resource "null_resource" "execute_ansible" {
  count = var.strongswan_ansible_setup ? 1 : 0
  triggers = {
    timestamp = timestamp()
  }
  provisioner "local-exec" {
    command = "ansible-playbook playbook.yml -e 'strongswan_password=\"${var.strongswan_password}\"' "
    working_dir = var.ansible_project_path
  }
  depends_on = [local_file.ansible_hosts, module.network1, module.network2]
}