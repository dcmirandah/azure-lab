resource "azurerm_resource_group" "kv_rg" {
  name     = "rg-${random_pet.rg.id}"
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                     = "kv-${random_pet.kv.id}"
  location                 = azurerm_resource_group.kv_rg.location
  resource_group_name      = azurerm_resource_group.kv_rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false
}
