terraform {
  required_version = ">= 1.6.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" } }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "foldermanager/functionapp/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" { features {} use_oidc = true }

data "azurerm_resource_group" "rg" { name = var.resource_group_name }
data "azurerm_key_vault" "kv"      { name = var.key_vault_name; resource_group_name = var.resource_group_name }

# Dedicated storage for Function App runtime
resource "azurerm_storage_account" "func_storage" {
  name                     = var.func_storage_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "ai-${var.function_app_name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  application_type    = "Node.JS"
  tags                = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = "plan-fn-${var.function_app_name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"  # Consumption — 1M free executions/month
  tags                = var.tags
}

resource "azurerm_linux_function_app" "fn" {
  name                       = var.function_app_name
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  tags                       = var.tags

  site_config {
    application_stack { node_version = "20" }
    application_insights_connection_string = azurerm_application_insights.ai.connection_string
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"    = "node"
    "DOCUMENT_STORAGE_ACCOUNT"    = var.document_storage_account_name
    "DOCUMENT_CONTAINER"          = "documents"
    "PROCESSED_CONTAINER"         = "processed"
    "DOC_INTELLIGENCE_ENDPOINT"   = var.doc_intelligence_endpoint
    "DOC_INTELLIGENCE_KEY"        = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/doc-intelligence-key/)"
    "AZURE_OPENAI_ENDPOINT"       = var.openai_endpoint
    "AZURE_OPENAI_KEY"            = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/openai-api-key/)"
    "AZURE_SEARCH_ENDPOINT"       = var.search_endpoint
    "AZURE_SEARCH_KEY"            = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/search-admin-key/)"
    "COSMOS_CONNECTION_STRING"    = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.kv.vault_uri}secrets/cosmos-connection-string/)"
  }

  identity { type = "SystemAssigned" }
}

resource "azurerm_role_assignment" "kv_access" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.fn.identity[0].principal_id
}

output "function_app_url"          { value = "https://${azurerm_linux_function_app.fn.default_hostname}" }
output "function_app_name"         { value = azurerm_linux_function_app.fn.name }
output "app_insights_conn_string"  { value = azurerm_application_insights.ai.connection_string; sensitive = true }
output "func_principal_id"         { value = azurerm_linux_function_app.fn.identity[0].principal_id }
