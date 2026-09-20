variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account"
}

variable "account_tier" {
  type        = string
  description = "The storage account tier (e.g., Standard, Premium)"
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "The storage account replication type (e.g., LRS, GRS, ZRS)"
  default     = "LRS"
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
