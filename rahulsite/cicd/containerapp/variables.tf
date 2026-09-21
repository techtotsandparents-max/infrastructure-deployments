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

variable "container_app_name" {
  type        = string
  description = "The name of the Web App for Containers running the LLM"
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
}

variable "subnet_integration_name" {
  type        = string
  description = "The name of the subnet for VNet integration"
}

variable "docker_image_name" {
  type        = string
  description = "The Docker image name and tag for the offline LLM"
  default     = "rahultech/offline-llm:latest"
}

variable "docker_registry_url" {
  type        = string
  description = "The URL of the Docker registry"
  default     = "https://index.docker.io/v1/"
}

variable "model_path" {
  type        = string
  description = "Path to the offline LLM model in the container"
  default     = "/models/offline-llm.bin"
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
