terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "foldermanager/storageaccount/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" { features {} use_oidc = true }

data "azurerm_resource_group" "rg"   { name = var.resource_group_name }
data "azurerm_key_vault" "kv"        { name = var.key_vault_name; resource_group_name = var.resource_group_name }

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  blob_properties {
    versioning_enabled = true
    delete_retention_policy { days = 7 }
    container_delete_retention_policy { days = 7 }
  }
}

resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.sa.id
  rule {
    name    = "archive-processed"
    enabled = true
    filters { blob_types = ["blockBlob"]; prefix_match = ["processed/"] }
    actions {
      base_blob { tier_to_cool_after_days_since_modification_greater_than = 90 }
    }
  }
}

# Store connection string in Key Vault
resource "azurerm_key_vault_secret" "conn_string" {
  name         = "storage-connection-string"
  value        = azurerm_storage_account.sa.primary_connection_string
  key_vault_id = data.azurerm_key_vault.kv.id
}

output "storage_account_name"     { value = azurerm_storage_account.sa.name }
output "primary_blob_endpoint"    { value = azurerm_storage_account.sa.primary_blob_endpoint }
output "documents_container_name" { value = azurerm_storage_container.documents.name }
output "processed_container_name" { value = azurerm_storage_container.processed.name }
