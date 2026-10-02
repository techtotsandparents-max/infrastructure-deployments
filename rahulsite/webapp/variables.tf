variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region"
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the shared App Service Plan"
}

variable "webapp_name" {
  type        = string
  description = "The name of the Web App"
}

variable "node_version" {
  type        = string
  description = "Node.js version for the Linux Web App"
  default     = "24-lts"
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
}

variable "subnet_integration_name" {
  type        = string
  description = "The name of the subnet for VNet integration"
}

variable "subnet_endpoints_name" {
  type        = string
  description = "The name of the subnet for private endpoints"
}

variable "private_ip_address" {
  type        = string
  description = "Static IP for the primary private endpoint member (optional)"
  default     = null
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault used for references"
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
