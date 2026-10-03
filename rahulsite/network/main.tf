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
    key                  = "rahulsite/network/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}

# The Resource Group might be managed centrally. If so, we'd use a data source.
# Using resource for this example to ensure it exists if deploying greenfield.
data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name

}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "snet_integration" {
  name                 = var.subnet_integration_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_integration_address_prefixes

  delegation {
    name = "webapp-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "snet_endpoints" {
  name                 = var.subnet_endpoints_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_endpoints_address_prefixes
  # Private endpoint network policies are disabled by default in newer azurerm versions, 
  # allowing private endpoints to be created in this subnet.
}
