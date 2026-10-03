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
    key                  = "rahulsite/cosmosdb/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet_endpoints" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}



# Identity resolution if identity_name is provided
data "azurerm_user_assigned_identity" "umi" {
  count               = var.identity_name != "" ? 1 : 0
  name                = var.identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmosdb_account_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  offer_type          = var.offer_type
  kind                = var.cosmosdb_kind

  free_tier_enabled             = var.free_tier_enabled
  public_network_access_enabled = false

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  backup {
    type = var.backup_tier == "Continuous30Days" || var.backup_tier == "Continuous7Days" ? "Continuous" : "Periodic"
    # Additional logic for Continuous30Days vs Continuous7Days would be handled in tier specific settings in newer provider versions
  }

  identity {
    type         = var.identity_name != "" ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_name != "" ? [data.azurerm_user_assigned_identity.umi[0].id] : null
  }
}

resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "${var.cosmosdb_account_name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_endpoints.id

  private_service_connection {
    name                           = "${var.cosmosdb_account_name}-privatelink"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    is_manual_connection           = false
    subresource_names              = ["MongoDB"]
  }

  dynamic "ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name               = "primary-ip"
      private_ip_address = var.private_ip_address
      member_name        = "MongoDB"
      subresource_name   = "MongoDB"
    }
  }

  dynamic "ip_configuration" {
    for_each = var.private_ip_address_secondary != null ? [1] : []
    content {
      name               = "secondary-ip"
      private_ip_address = var.private_ip_address_secondary
      member_name        = "${var.cosmosdb_account_name}-${var.location}"
      subresource_name   = "MongoDB"
    }
  }
}
