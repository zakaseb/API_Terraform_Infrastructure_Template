resource "azurerm_storage_account" "callsign" {
  name                     = "callsigndata"
  resource_group_name      = azurerm_resource_group.callsign.name
  location                 = azurerm_resource_group.callsign.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "callsign" {
  name                  = "default"
  storage_account_name  = azurerm_storage_account.callsign.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "callsign_asa" {
  principal_id         = azurerm_user_assigned_identity.callsign.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.callsign.id
}
