terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "desk_market_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_mssql_server" "desk_market_sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.desk_market_rg.name
  location                     = azurerm_resource_group.desk_market_rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"

  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_database" "desk_market_sql_database" {
  name         = var.sql_db_name
  server_id    = azurerm_mssql_server.desk_market_sql_server.id
  max_size_gb  = 2
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  sku_name     = "Basic"
}

resource "azurerm_service_plan" "desk_market_sp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.desk_market_rg.name
  location            = azurerm_resource_group.desk_market_rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "desk_market" {
  name                = "desk-market"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.desk_market_sp.id

  app_settings = {
    "ConnectionStrings__DefaultConnection" = "Data Source=tcp:${azurerm_mssql_server.desk_market_sql_server.fully_qualified_domain_name}.database.windows.net;Database=${azurerm_mssql_database.desk_market_sql_database.name};User ID=${var.sql_admin_login};Password=${var.sql_admin_password};Trusted_Connection=False;MultipleActiveResultSets=True"
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "desk_market-sc" {
  app_id                 = azurerm_linux_web_app.desk_market.id
  repo_url               = "https://github.com/NinjataWRLD/Desk-Market"
  branch                 = "main"
  use_manual_integration = true
}
