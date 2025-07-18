# Groupe de sécurité réseau (NSG) pour autoriser le port 5000
resource "azurerm_network_security_group" "main" {
  security_rule {
    name                       = "Allow-SSH-22"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  name                = "nsg-aat"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-Flask-5000"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Association du NSG à la subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
provider "azurerm" {
  features {}
  subscription_id = "d18efcbe-caa9-4004-ac2c-7312261e11de"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-aat"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-main-aat"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-main-aat"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "nic-main-aat"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal-aat"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_public_ip" "main" {
  name                = "publicip-main-aat"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-ubuntu-aat"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.main.id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("C:/Users/aymen/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "main" {
  name                     = "${var.storage_account_name}aat"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Base de données MySQL managée Azure
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "mysql-aat-bdd"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false

  storage {
    size_gb = 32
  }
}

resource "azurerm_mysql_flexible_database" "main" {
  name                = "aatdb"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_storage_container" "main" {
  name                  = "static-files-aat"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

output "public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_admin_password" {
  value     = "@password123"
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_container_name" {
  value = azurerm_storage_container.main.name
}

