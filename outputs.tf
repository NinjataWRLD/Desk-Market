output "sql_server_name" {
  description = "The name of the SQL Server"
  value       = azurerm_mssql_server.desk_market_sql_server.name
}

output "web_app_url" {
  description = "The URL of the web application"
  value       = azurerm_linux_web_app.desk_market.default_hostname
}
