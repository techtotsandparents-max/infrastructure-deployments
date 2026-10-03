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
    key                  = "rahulsite/storageaccount/terraform.tfstate"
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


data "http" "runner_ip" {
  url = "https://ifconfig.me/ip"
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  public_network_access_enabled = true
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    ip_rules       = [data.http.runner_ip.response_body]
    bypass         = ["AzureServices"]
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "time_sleep" "wait_for_network_rules" {
  depends_on      = [azurerm_storage_account.sa]
  create_duration = "30s"
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.sa.name
  depends_on            = [time_sleep.wait_for_network_rules]
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "sa_blob_pe" {
  name                = "${var.storage_account_name}-blob-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet_endpoints.id

  private_service_connection {
    name                           = "${var.storage_account_name}-privatelink"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  dynamic "ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name               = "primary-ip"
      private_ip_address = var.private_ip_address
      member_name        = "blob"
      subresource_name   = "blob"
    }
  }
}
