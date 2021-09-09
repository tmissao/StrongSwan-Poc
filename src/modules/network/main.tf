resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  location = var.vnet_location
  resource_group_name = var.resource_group_name
  address_space = var.vnet_addresses
}

resource "azurerm_subnet" "subnet" {
  name = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_addresses
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.vnet_name}-vm"
  location            = var.vnet_location
  resource_group_name =  var.resource_group_name
  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ping"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm" {
  name = "${var.vnet_name}-vm"
  location = var.vnet_location
  resource_group_name = var.resource_group_name
  enable_ip_forwarding = true
  ip_configuration {
    name = "vm1"
    subnet_id = azurerm_subnet.subnet.id
    public_ip_address_id = var.bridge_vm_public_ip_id
    private_ip_address_allocation = "Static"
    private_ip_address = var.bridge_vm_private_ip
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = file("${path.module}/scripts/init.cfg")
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/strongswan.sh", {
      HOST_PRIVATE_IP = azurerm_network_interface.vm.private_ip_address
      HOST_PUBLIC_IP = var.bridge_vm_public_ip
      HOST_SUBNET = var.subnet_addresses[0]
      REMOTE_PUBLIC_IP = var.strongswan_right_public_ip
      REMOTE_SUBNET = var.strongswan_right_subnet
      STRONGSWAN_PASSWORD = var.strongswan_password
    })
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "${var.vnet_name}-vm"
  admin_username = "adminuser"
  location = var.vnet_location
  resource_group_name = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm.id]
  custom_data = var.strongswan_setup ? data.template_cloudinit_config.config.rendered : null
  size = "Standard_B2s"
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    caching = "None"
    storage_account_type = "Standard_LRS"
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  identity {
    type = "SystemAssigned"
  }
}