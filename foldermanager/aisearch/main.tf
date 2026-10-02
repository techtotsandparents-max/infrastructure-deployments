terraform {
  required_version = ">= 1.6.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" } }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "foldermanager/aisearch/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" { features {} use_oidc = true }

data "azurerm_resource_group" "rg" { name = var.resource_group_name }
data "azurerm_key_vault" "kv"      { name = var.key_vault_name; resource_group_name = var.resource_group_name }

resource "azurerm_search_service" "search" {
  name                = var.search_service_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = var.sku  # "free" = 50MB, 3 indexes — enough for dev/early prod
  replica_count       = 1
  partition_count     = 1
  tags                = var.tags
}

resource "azurerm_key_vault_secret" "search_key" {
  name         = "search-admin-key"
  value        = azurerm_search_service.search.primary_key
  key_vault_id = data.azurerm_key_vault.kv.id
}

output "search_endpoint" { value = "https://${azurerm_search_service.search.name}.search.windows.net" }
output "search_name"     { value = azurerm_search_service.search.name }
