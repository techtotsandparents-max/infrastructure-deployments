terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {}
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



# Identity resolution if identity_name is provided
data "azurerm_user_assigned_identity" "umi" {
  count               = var.identity_name != "" ? 1 : 0
  name                = var.identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_linux_web_app" "llm_container" {
  name                = var.container_app_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.asp.id

  virtual_network_subnet_id = data.azurerm_subnet.snet_integration.id
  https_only                = true
  public_network_access_enabled = true # True because we are using IP restrictions instead of PE for internal VNet routing on this specific App

  site_config {
    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = var.docker_registry_url
    }
    vnet_route_all_enabled = true
    always_on              = true
    
    # Restrict access so only traffic from within the VNet can hit this LLM endpoint
    ip_restriction {
      name                      = "AllowVNetTrafficOnly"
      virtual_network_subnet_id = data.azurerm_subnet.snet_integration.id
      priority                  = 100
      action                    = "Allow"
    }
  }

  identity {
    type         = var.identity_name != "" ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_name != "" ? [data.azurerm_user_assigned_identity.umi[0].id] : null
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "MODEL_PATH" = var.model_path
  }
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "llm_kv_access" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.llm_container.identity[0].principal_id
}
