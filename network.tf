# Récupération des informations du réseau existant
data "azurerm_virtual_network" "tp4_vnet" {
  name                = "network-tp4"
  resource_group_name = var.resource_group
}

# Récupération des informations du sous-réseau existant
data "azurerm_subnet" "internal_subnet" {
  name                 = "internal"
  virtual_network_name = data.azurerm_virtual_network.tp4_vnet.name
  resource_group_name  = var.resource_group
}

# Création de l'interface réseau
resource "azurerm_network_interface" "devops_ni" {
  name                = "devops-ni"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.internal_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops_public_ip.id
  }
}

# Création de l'adresse IP publique
resource "azurerm_public_ip" "devops_public_ip" {
  name                = "devops-public-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
}
