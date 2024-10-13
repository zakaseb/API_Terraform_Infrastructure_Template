resource "azurerm_virtual_network" "callsign" {
  name                = "callsign"
  resource_group_name = azurerm_resource_group.callsign.name
  location            = azurerm_resource_group.callsign.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "callsign" {
  name                 = "callsign"
  resource_group_name  = azurerm_resource_group.callsign.name
  virtual_network_name = azurerm_virtual_network.callsign.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_public_ip" "callsign" {
  name                = "callsign"
  resource_group_name = azurerm_resource_group.callsign.name
  location            = azurerm_resource_group.callsign.location
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "callsign" {
  name                = "callsign"
  resource_group_name = azurerm_resource_group.callsign.name
  location            = azurerm_resource_group.callsign.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "default"
    subnet_id = azurerm_subnet.callsign.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "default"
    public_ip_address_id = azurerm_public_ip.callsign.id
  }

  backend_address_pool {
    name  = "callsign"
    fqdns = [azurerm_container_app.callsign.latest_revision_fqdn]
  }

  backend_http_settings {
    name                                = "http"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    probe_name                          = "health"
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "default"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "http"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "callsign"
    backend_http_settings_name = "http"
  }

  probe {
    name                                      = "health"
    protocol                                  = "Http"
    path                                      = "/health"
    interval                                  = 30
    timeout                                   = 20
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    port                                      = 80
  }
}
