resource "azurerm_log_analytics_workspace" "callsign" {
  name                = "callsign"
  location            = azurerm_resource_group.callsign.location
  resource_group_name = azurerm_resource_group.callsign.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "callsign" {
  name                       = "callsign"
  location                   = azurerm_resource_group.callsign.location
  resource_group_name        = azurerm_resource_group.callsign.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.callsign.id
}

resource "azurerm_container_app" "callsign" {
  name                         = "callsign"
  container_app_environment_id = azurerm_container_app_environment.callsign.id
  resource_group_name          = azurerm_resource_group.callsign.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.callsign.id]
  }

  template {
    container {
      name   = "callsign"
      image  = "${azurerm_container_registry.callsign.login_server}/callsign:${var.app_version}"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas = 1
    max_replicas = 10

    custom_scale_rule {
      name             = "cpu"
      custom_rule_type = "cpu"
      metadata = {
        value = 80
      }
    }

    custom_scale_rule {
      name             = "memory"
      custom_rule_type = "memory"
      metadata = {
        value = 80
      }
    }
  }

  ingress {
    transport        = "http"
    target_port      = 8887
    external_enabled = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [azurerm_role_assignment.callsign_acr]
}

resource "azurerm_container_registry" "callsign" {
  name                          = "callsign"
  resource_group_name           = azurerm_resource_group.callsign.name
  location                      = azurerm_resource_group.callsign.location
  sku                           = "Standard"
  anonymous_pull_enabled        = true
  public_network_access_enabled = true
}

resource "azurerm_role_assignment" "callsign_acr" {
  principal_id         = azurerm_user_assigned_identity.callsign.principal_id
  role_definition_name = "Container Registry Repository Contributor"
  scope                = azurerm_container_registry.callsign.id
}

resource "azurerm_user_assigned_identity" "callsign" {
  name                = "callsign"
  location            = azurerm_resource_group.callsign.location
  resource_group_name = azurerm_resource_group.callsign.name
}


