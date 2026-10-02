variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "webapp_name" { type = string }
variable "app_service_plan_name" { type = string }
variable "node_version" { type = string; default = "20-lts" }
variable "tags" { type = map(string); default = {} }

resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = var.tags
}

resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true
  tags                = var.tags

  site_config {
    always_on = false
    application_stack {
      node_version = var.node_version
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

output "webapp_url" {
  value = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}

output "principal_id" {
  value = azurerm_linux_web_app.webapp.identity[0].principal_id
}
