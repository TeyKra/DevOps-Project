# Définition de la variable pour le groupe de ressources
variable "resource_group" {
  default = "ADDA84-CTP" # Valeur par défaut du nom du groupe de ressources
}

# Définition de la variable pour l'emplacement
variable "location" {
  default = "francecentral" # Valeur par défaut de l'emplacement
}

# Définition de la variable pour l'identifiant unique de la VM
variable "identifiant_efrei" {
  type        = string                                     # Type de la variable (chaîne de caractères)
  description = "Identifiant unique pour le nom de la VM." # Description de la variable
}
