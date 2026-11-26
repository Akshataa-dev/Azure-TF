output "resource_group_name" {
  value = azurerm_resource_group.rg.name


}

output "web_app_hostname" {
  value = azurerm_linux_web_app.webapp.default_hostname
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name

}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name

}

output "sql_server_name" {
  value = azurerm_mssql_server.sqlserver.name

}
output "sql_database_name" {
  value = azurerm_mssql_database.sqldb.name

}