# Déclaration de la version Terraform utilisée et des fournisseurs requis
terraform {
  required_providers {
    # Fournisseur Azure
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # Fournisseur TLS
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1"
    }
  }
  # Configuration du backend pour stocker l'état Terraform localement
  backend "local" {
    path = "terraform.tfstate" # Chemin où l'état Terraform sera enregistré localement
  }
}

# Configuration du fournisseur Azure
provider "azurerm" {
  features {}                       # Activation des fonctionnalités supplémentaires du fournisseur Azure
  skip_provider_registration = true # Ignorer l'enregistrement automatique du fournisseur Azure
}
