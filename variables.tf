variable "admin_password" {
  description = "Mot de passe admin pour la VM."
  type        = string
  sensitive   = true
  default     = null
}


variable "resource_group_name" {
  description = "Nom du groupe de ressources Azure."
  type        = string
  default     = "Projet-cloud-aat"
}

variable "location" {
  description = "Région Azure."
  type        = string
  default     = "westeurope"
}


variable "admin_username" {
  description = "Nom d'utilisateur admin pour la VM."
  type        = string
  default     = "aat-cloud"
}


variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH."
  type        = string
  default     = "C:/Users/aymen/.ssh/id_rsa_azure.pub"
}

variable "vm_size" {
  description = "Taille de la VM."
  type        = string
  default     = "Standard_B1s"
}

variable "storage_account_name" {
  description = "Nom du compte de stockage Azure (doit être unique, 3-24 caractères, minuscules et chiffres)."
  type        = string
  default     = "aatstorage123"
}

variable "mysql_admin_username" {
  description = "Nom d'utilisateur admin MySQL."
  type        = string
  default     = "mysqladmin"
}

variable "mysql_admin_password" {
  description = "Mot de passe admin MySQL."
  type        = string
  sensitive   = true
  default     = "@password123"
}


