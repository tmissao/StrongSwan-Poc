[control]
localhost

[vms]
vm1 ansible_host='${vm1_public_ip}' private_ip='${vm1_private_ip}' subnet_address_space='${vm1_subnet}' strongswan_right_address='${vm2_public_ip}' strongswan_right_subnet='${vm2_subnet}'
vm2 ansible_host='${vm2_public_ip}' private_ip='${vm2_private_ip}' subnet_address_space='${vm2_subnet}' strongswan_right_address='${vm1_public_ip}' strongswan_right_subnet='${vm1_subnet}'