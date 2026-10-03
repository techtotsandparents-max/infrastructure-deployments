terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformrahultech"
    container_name       = "tfstate"
    key                  = "rahulsite/webapp/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.app_service_plan_resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet_integration" {
  name                 = var.subnet_integration_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet_endpoints" {
  name                 = var.subnet_endpoints_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}



# Identity resolution if identity_name is provided
data "azurerm_user_assigned_identity" "umi" {
  count               = var.identity_name != "" ? 1 : 0
  name                = var.identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.asp.id

  virtual_network_subnet_id     = data.azurerm_subnet.snet_integration.id
  https_only                    = true
  public_network_access_enabled = false

  site_config {
    application_stack {
      node_version = var.node_version
    }
    vnet_route_all_enabled = true
    always_on              = true
  }

  identity {
    type         = var.identity_name != "" ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_name != "" ? [data.azurerm_user_assigned_identity.umi[0].id] : null
  }

  app_settings = {
    # Placeholders for KV references. Actual secret names depend on KV setup.
    "COSMOS_DB_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=https://${var.key_vault_name}.vault.azure.net/secrets/COSMOS-DB-CONNECTION-STRING/)"
    "AZURE_STORAGE_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=https://${var.key_vault_name}.vault.azure.net/secrets/AZURE-STORAGE-CONNECTION-STRING/)"
    "NEXTAUTH_SECRET" = "@Microsoft.KeyVault(SecretUri=https://${var.key_vault_name}.vault.azure.net/secrets/NEXTAUTH-SECRET/)"
    # Add other settings as needed
  }
}

resource "azurerm_private_endpoint" "webapp_pe" {
  name                = "${var.webapp_name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_endpoints.id

  private_service_connection {
    name                           = "${var.webapp_name}-privatelink"
    private_connection_resource_id = azurerm_linux_web_app.webapp.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  dynamic "ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name               = "primary-ip"
      private_ip_address = var.private_ip_address
      member_name        = "sites"
      subresource_name   = "sites"
    }
  }
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "webapp_kv_access" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}
