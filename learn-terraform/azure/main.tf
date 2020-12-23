# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name = "myTFResourceGroup"
  location = "westus2"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name = "myTFVnet"
  address_space = ["10.10.10.0/24"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
    default     = "azureuser"
}

variable "admin_password" {
    type = string
    description = "Password must meet Azure complexity requirements"
    default     = "P@ssw0rd1234!"
}

# Create subnets
resource "azurerm_subnet" "subnet1" {
  name                 = "myBESubnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.10.0/25"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "myBESubnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.10.128/25"]
}
# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "myPublicIPForLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSG"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "httpSHG"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associates a Network Security Group with a Subnet within a Virtual Network.
resource "azurerm_subnet_network_security_group_association" "sn1_nsg_ass" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "sn2_nsg_ass" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create load balancer and rules
resource "azurerm_lb" "lb" {
  name                = "myLoadBalancer"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_outbound_rule" "outboundrule" {
  resource_group_name     = azurerm_resource_group.rg.name
  loadbalancer_id         = azurerm_lb.lb.id
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}

resource "azurerm_lb_rule" "frontendrule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Create network interface
resource "azurerm_network_interface" "nic1" {
  name                     = "myNIC1"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNic1Config"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "nic1" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "myNic1Config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}

# Create a virtual machine
resource "azurerm_virtual_machine" "vm1" {
  name                  = "myTFVM-1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_B1S"
  zones                 = ["1"]

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myTFVM-1"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# create a Linux virtual machine #2
resource "azurerm_network_interface" "nic2" {
  name                     = "myNIC2"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNic2Config"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic2be-ass" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = "myNic2Config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                  = "example-machine"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1S"
  admin_username        = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]
  zone                 = "1"
  
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}



output "azurerm_public_ip" {
  value = azurerm_public_ip.publicip.id
}