# StrongSwan Poc

This project intends to build an IpSec VPN using StrongSwan. In order to do that, two Virtual Machines are created in two distinct subnets and a VPN is setup to allow communication between them.

## Setup
---

- [Create an Azure Account](https://azure.microsoft.com/en-us/free/)
- [Install TF_ENV](https://github.com/tfutils/tfenv)
- Public SSH Key located on `~/.ssh/id_rsa.pub`

## How it Works ?
---

The current terraform code builds the following architecture:

![user-case](./artifacts/case.png)

So, two Vnets completely isolated are created, and each vnet contains a subnet and a virtual machine with a public ip. Using StrongSwan a VPN is built allowing the the VMs reach each other.

## Usage
---

```bash
tfenv install
tfenv use
terraform init
terraform apply
```

## Results
---
![results](./artifacts/result.gif)

## References
---

 - [Tunneling between AWS & Azure](https://faun.pub/tunneling-aws-to-azure-e23d0defb971)