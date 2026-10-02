terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "foldermanager/keyvault/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" { features { key_vault { purge_soft_delete_on_destroy = false } } use_oidc = true }

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" { name = var.resource_group_name }

resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = var.tags

  # CI/CD principal — full access to seed secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

# Managed Identity for app to read secrets
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "umi-${var.key_vault_name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app_identity.principal_id
  secret_permissions = ["Get", "List"]
}

output "key_vault_id"          { value = azurerm_key_vault.kv.id }
output "key_vault_uri"         { value = azurerm_key_vault.kv.vault_uri }
output "key_vault_name"        { value = azurerm_key_vault.kv.name }
output "app_identity_id"       { value = azurerm_user_assigned_identity.app_identity.id }
output "app_identity_client_id"{ value = azurerm_user_assigned_identity.app_identity.client_id }
