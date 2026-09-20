variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region"
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space for the virtual network"
}

variable "subnet_integration_name" {
  type        = string
  description = "The name of the subnet for VNet integration"
}

variable "subnet_integration_address_prefixes" {
  type        = list(string)
  description = "The address prefixes for the integration subnet"
}

variable "subnet_endpoints_name" {
  type        = string
  description = "The name of the subnet for private endpoints"
}

variable "subnet_endpoints_address_prefixes" {
  type        = list(string)
  description = "The address prefixes for the private endpoints subnet"
}

variable "import_to_state" {
  type        = bool
  description = "Flag to indicate if resources are being imported to state"
  default     = false
}
