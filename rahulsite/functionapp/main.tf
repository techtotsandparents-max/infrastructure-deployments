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
    key                  = "rahulsite/functionapp/terraform.tfstate"
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
  resource_group_name = data.azurerm_resource_group.rg.name
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

data "azurerm_storage_account" "sa" {
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
}



# Identity resolution if identity_name is provided
data "azurerm_user_assigned_identity" "umi" {
  count               = var.identity_name != "" ? 1 : 0
  name                = var.identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_linux_function_app" "func" {
  name                = var.function_app_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.asp.id

  storage_account_name       = data.azurerm_storage_account.sa.name
  storage_account_access_key = data.azurerm_storage_account.sa.primary_access_key

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
    "KEY_VAULT_URI" = "https://${var.key_vault_name}.vault.azure.net/"
  }
}

resource "azurerm_private_endpoint" "func_pe" {
  name                = "${var.function_app_name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_endpoints.id

  private_service_connection {
    name                           = "${var.function_app_name}-privatelink"
    private_connection_resource_id = azurerm_linux_function_app.func.id
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

resource "azurerm_role_assignment" "func_kv_access" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.func.identity[0].principal_id
}
