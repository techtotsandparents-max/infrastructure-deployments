variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region"
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault"
}

variable "sku_name" {
  type        = string
  description = "The Name of the SKU used for this Key Vault (standard or premium)"
  default     = "standard"
}

variable "soft_delete_retention_days" {
  type        = number
  description = "The number of days that items should be retained for once soft-deleted"
  default     = 7
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Is Purge Protection enabled for this Key Vault?"
  default     = false
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet for private endpoints"
}

variable "private_ip_address" {
  type        = string
  description = "Static IP for the primary private endpoint member (optional)"
  default     = null
}

variable "import_to_state" {
  type        = bool
  description = "Flag to indicate if resources are being imported to state"
  default     = false
}
