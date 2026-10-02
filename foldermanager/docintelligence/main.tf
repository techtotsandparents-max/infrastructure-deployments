terraform {
  required_version = ">= 1.6.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" } }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "foldermanager/docintelligence/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" { features { cognitive_account { purge_soft_delete_on_destroy = false } } use_oidc = true }

data "azurerm_resource_group" "rg" { name = var.resource_group_name }
data "azurerm_key_vault" "kv"      { name = var.key_vault_name; resource_group_name = var.resource_group_name }

resource "azurerm_cognitive_account" "di" {
  name                = var.doc_intelligence_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = "FormRecognizer"
  sku_name            = var.sku_name  # F0 = free; S0 = standard
  tags                = var.tags
}

resource "azurerm_key_vault_secret" "di_key" {
  name         = "doc-intelligence-key"
  value        = azurerm_cognitive_account.di.primary_access_key
  key_vault_id = data.azurerm_key_vault.kv.id
}

output "endpoint"     { value = azurerm_cognitive_account.di.endpoint }
output "resource_id"  { value = azurerm_cognitive_account.di.id }
