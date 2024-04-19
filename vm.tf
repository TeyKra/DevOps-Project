# Définition de la ressource Azure VM Linux
resource "azurerm_linux_virtual_machine" "devops_vm" {
  # Nom de la machine virtuelle
  name = "devops-${var.identifiant_efrei}"
  # Emplacement de la ressource
  location = var.location
  # Groupe de ressources auquel la machine virtuelle est associée
  resource_group_name = var.resource_group
  # ID de l'interface réseau à attacher à la machine virtuelle
  network_interface_ids = [azurerm_network_interface.devops_ni.id]
  # Taille de la machine virtuelle
  size = "Standard_D2s_v3"

  # Configuration du disque système
  os_disk {
    name                 = "myosdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Référence de l'image source
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Nom d'utilisateur de l'administrateur
  admin_username = "devops"
  # Désactiver l'authentification par mot de passe
  disable_password_authentication = true
  # Configuration de la clé SSH de l'administrateur
  admin_ssh_key {
    username   = "devops"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  # Données personnalisées à injecter dans la machine virtuelle (script d'installation Docker)
  custom_data = base64encode(file("${path.module}/Install-docker.yml"))
}

# Génération de la paire de clés SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Enregistrement de la clé publique SSH dans un fichier local
resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/id_rsa.pub"
}

# Enregistrement de la clé privée SSH dans un fichier local sécurisé
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/id_rsa"
  file_permission = "0600"
}
