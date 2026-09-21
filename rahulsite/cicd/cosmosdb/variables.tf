variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region"
}

variable "cosmosdb_account_name" {
  type        = string
  description = "The name of the Cosmos DB account"
}

variable "cosmosdb_kind" {
  type        = string
  description = "The API kind for Cosmos DB (e.g., MongoDB, GlobalDocumentDB)"
  default     = "MongoDB"
}

variable "free_tier_enabled" {
  type        = bool
  description = "Enable Cosmos DB free tier"
  default     = false
}

variable "offer_type" {
  type        = string
  description = "The offer type for the Cosmos DB account"
  default     = "Standard"
}

variable "consistency_level" {
  type        = string
  description = "The consistency level for Cosmos DB"
  default     = "Session"
}

variable "backup_tier" {
  type        = string
  description = "The backup policy tier (e.g., Continuous30Days, Periodic)"
  default     = "Continuous30Days"
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

variable "private_ip_address_secondary" {
  type        = string
  description = "Static IP for the secondary regional private endpoint member (optional)"
  default     = null
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault"
  default     = ""
}

variable "key_vault_resource_group_name" {
  type        = string
  description = "The resource group of the Key Vault"
  default     = ""
}

variable "identity_name" {
  type        = string
  description = "The name of the User Assigned Managed Identity (optional)"
  default     = ""
}



variable "import_to_state" {
  type        = bool
  description = "Flag to indicate if resources are being imported to state"
  default     = false
}
