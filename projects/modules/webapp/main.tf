resource "azurerm_resource_group" "rg" {
  name     = "rg-${random_pet.pet.id}"
  location = var.location
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "asp-${random_pet.pet.id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "F1" # Free tier
}

# Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "app-${random_pet.pet.id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
    always_on = false
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITE_RUN_FROM_PACKAGE            = var.zip_package_url
  }
}

