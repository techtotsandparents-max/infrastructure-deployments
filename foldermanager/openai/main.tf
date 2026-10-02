terraform {
  required_version = ">= 1.6.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" } }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "foldermanager/openai/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" { features { cognitive_account { purge_soft_delete_on_destroy = false } } use_oidc = true }

data "azurerm_resource_group" "rg" { name = var.resource_group_name }
data "azurerm_key_vault" "kv"      { name = var.key_vault_name; resource_group_name = var.resource_group_name }

resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_account_name
  location            = "eastus" # OpenAI availability
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  tags                = var.tags
}

resource "azurerm_cognitive_deployment" "gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model { format = "OpenAI"; name = "gpt-4o"; version = "2024-08-06" }
  sku { name = "Standard"; capacity = var.gpt_capacity }
}

resource "azurerm_cognitive_deployment" "embedding" {
  name                 = "text-embedding-3-large"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model { format = "OpenAI"; name = "text-embedding-3-large"; version = "1" }
  sku { name = "Standard"; capacity = var.embedding_capacity }
}

resource "azurerm_key_vault_secret" "openai_key" {
  name         = "openai-api-key"
  value        = azurerm_cognitive_account.openai.primary_access_key
  key_vault_id = data.azurerm_key_vault.kv.id
}

output "openai_endpoint"     { value = azurerm_cognitive_account.openai.endpoint }
output "gpt_deployment"      { value = azurerm_cognitive_deployment.gpt4o.name }
output "embedding_deployment"{ value = azurerm_cognitive_deployment.embedding.name }
