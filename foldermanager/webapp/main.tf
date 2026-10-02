terraform {
  required_version = ">= 1.6.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" } }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "foldermanager/webapp/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" { features {} use_oidc = true }

data "azurerm_resource_group" "rg"         { name = var.resource_group_name }
data "azurerm_virtual_network" "vnet"      { name = var.virtual_network_name; resource_group_name = var.resource_group_name }
data "azurerm_subnet" "app"                { name = var.subnet_integration_name; virtual_network_name = var.virtual_network_name; resource_group_name = var.resource_group_name }
data "azurerm_key_vault" "kv"              { name = var.key_vault_name; resource_group_name = var.resource_group_name }

resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "webapp" {
  name                      = var.webapp_name
  location                  = var.location
  resource_group_name       = data.azurerm_resource_group.rg.name
  service_plan_id           = azurerm_service_plan.asp.id
  virtual_network_subnet_id = data.azurerm_subnet.app.id
  https_only                = true
  tags                      = var.tags

  site_config {
    always_on         = false
    ftps_state        = "Disabled"
    health_check_path = "/api/health"
    application_stack { node_version = var.node_version }
  }

  app_settings = {
    "NODE_ENV"               = "production"
    "STORAGE_CONNECTION"     = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/storage-connection-string/)"
    "OPENAI_KEY"             = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/openai-api-key/)"
    "SEARCH_KEY"             = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/search-admin-key/)"
    "DOC_INTELLIGENCE_KEY"   = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/doc-intelligence-key/)"
    "NEXTAUTH_SECRET"        = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/nextauth-secret/)"
  }

  identity { type = "SystemAssigned" }
}

resource "azurerm_role_assignment" "kv_access" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.webapp.id
  https_only     = true
  tags           = var.tags
  site_config {
    always_on = false
    application_stack { node_version = var.node_version }
  }
  app_settings           = azurerm_linux_web_app.webapp.app_settings
  identity { type = "SystemAssigned" }
}

output "webapp_url"          { value = "https://${azurerm_linux_web_app.webapp.default_hostname}" }
output "webapp_staging_url"  { value = "https://${azurerm_linux_web_app_slot.staging.default_hostname}" }
output "webapp_principal_id" { value = azurerm_linux_web_app.webapp.identity[0].principal_id }
