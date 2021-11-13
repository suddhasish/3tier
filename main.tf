provider "azurerm" {
  features {}
}

module "resourcegroup" {
  source         = "./resource_group"
  name           = var.name
  location       = var.location
}

module "networking" {
  source         = "./Network"
  location       = module.resourcegroup.location_id
  resource_group = module.resourcegroup.resource_group_name
  vnetname       = var.vnet_name
  vnetcidr       = var.vnet_cidr
  agwsubnetname  = var.agwsubnet_name
  agwsubnetcidr  = var.agwsubnet_cidr
  websubnetname  = var.websubnet_name
  websubnetcidr  = var.websubnet_cidr
  appsubnetname  = var.appsubnet_name
  appsubnetcidr  = var.appsubnet_cidr
  dbsubnetname   = var.dbsubnet_name
  dbsubnetcidr   = var.dbsubnet_cidr
  agwsubnetid    = azurerm_subnet.agwtiersubnet.id
  websubnetid    = azurerm_subnet.webtiersubnet.id
  appsubnetid    = azurerm_subnet.datatiersubnet.id
  dbsubnetid     = azurerm_subnet.apptiersubnet.id 
}