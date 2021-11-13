resource "azurerm_virtual_network" "tier3vnet"{
name = var.vnetname
resource_group_name = var.resource_group
location            = var.location
address_space       = [var.vnetcidr]
}

resource "azurerm_subnet" "agwtiersubnet"{
name = var.agwsubnetname
virtual_network_name = azurerm_virtual_network.tiervnet.name
resource_group_name  = var.resource_group
address_prefixes     = [var.agwsubnetcidr]
}

resource "azurerm_subnet" "webtiersubnet"{
name = var.websubnetname
virtual_network_name = azurerm_virtual_network.tier3vnet.name
resource_group_name  = var.resource_group
address_prefixes     = [var.websubnetcidr]
}

resource "azurerm_subnet" "apptiersubnet"{
name = var.appsubnetname
virtual_network_name = azurerm_virtual_network.tier3vnet.name
resource_group_name  = var.resource_group
address_prefixes     = [var.appsubnetcidr]
}

resource "azurerm_subnet" "datatiersubnet"{
name = var.dbsubnetname
virtual_network_name = azurerm_virtual_network.tier3vnet.name
resource_group_name  = var.resource_group
address_prefixes     = [var.dbsubnetcidr]
}

resource "azurerm_network_security_group" "agwtiernsg" {
  name                = "agwtier-nsg"
  location            = var.location
  resource_group_name = var.resource_group
  
  security_rule {
    name                       = "allowwebagw-1"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "443,80"
    destination_address_prefix = var.agwsubnetcidr
    destination_port_range     = "22"
  }
  
  security_rule {
    name                       = "allowhealthprobeagw-2"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = ["65503-65534"]
  }

  security_rule {
    name                       = "allowoutboundhttpsagw-2"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.agwsubnetcidr
    source_port_range          = "*"
    destination_address_prefix = var.websubnetcidr
    destination_port_range     = "443"
  }

}

resource "azurerm_subnet_network_security_group_association" "agwtiernsgsubnetassociation" {
  subnet_id                 = var.agwsubnetid
  network_security_group_id = azurerm_network_security_group.agwtiernsg.id 
}

resource "azurerm_network_security_group" "webtiernsg" {
  name                = "webtier-nsg"
  location            = var.location
  resource_group_name = var.resource_group
  
  security_rule {
    name                       = "sshrule-1"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.vnetcidr
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
  
  security_rule {
    name                       = "httpsrule-2"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.agwsubnetcidr
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "webtoapprule-1"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.websubnetcidr
    source_port_range          = "*"
    destination_address_prefix = var.appsubnetcidr
    destination_port_range     = "8080"
  }
}

resource "azurerm_subnet_network_security_group_association" "webtiernsgsubnetassociation" {
  subnet_id                 = var.websubnetid
  network_security_group_id = azurerm_network_security_group.webtiernsg.id 
}

resource "azurerm_network_security_group" "apptiernsg" {
  name                = "apptier-nsg"
  location            = var.location
  resource_group_name = var.resource_group
  
  security_rule {
    name                       = "sshrule-1"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.vnetcidr
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
  
  security_rule {
    name                       = "httpsrule-2"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.websubnetcidr
    source_port_range          = "*"
    destination_address_prefix = var.appsubnetcidr
    destination_port_range     = "8080"
  }
    security_rule {
    name                       = "dbconnectivityrule-1"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.appsubnetcidr
    source_port_range          = "*"
    destination_address_prefix = var.dbsubnetcidr
    destination_port_range     = "8080"
  }

}

resource "azurerm_subnet_network_security_group_association" "apptiernsgsubnetassociation" {
  subnet_id                 = var.appsubnetid
  network_security_group_id = azurerm_network_security_group.apptiernsg.id 
}

resource "azurerm_network_security_group" "dbtiernsg" {
  name                = "dbtier-nsg"
  location            = var.location
  resource_group_name = var.resource_group
  
    security_rule {
        name = "dbrule-1"
        priority = 101
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_address_prefix = "192.168.2.0/24"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "3306"
    }
       
}

resource "azurerm_subnet_network_security_group_association" "dbtiernsgsubnetassociation" {
  subnet_id                 = var.dbsubnetid
  network_security_group_id = azurerm_network_security_group.dbtiernsg.id
}
