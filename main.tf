locals {
  common_tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Project     = "DevOpsAssignment"
    Owner       = var.owner
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-dev"
  location = var.location

  tags = local.common_tags

}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devops-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.10.0.0/16"]

  tags = local.common_tags

}

resource "azurerm_subnet" "app" {
  name                 = "snet-app-dev"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.10.1.0/24"]

}

resource "azurerm_subnet" "private" {
  name                 = "snet-pe-dev"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.10.2.0/24"]

  private_endpoint_network_policies = "Disabled"

}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "nsg-app-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name      = "allow-http"
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_port_range      = "*"
    destination_port_range = "80"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = local.common_tags

}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id

}

resource "azurerm_storage_account" "storage" {
  name                = "stgdev${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = local.common_tags



}

resource "azurerm_storage_container" "container" {
  name                  = "project-private-data"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"

}

data "azurerm_client_config" "current" {


}

resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  tags = local.common_tags

}

resource "azurerm_service_plan" "plan" {
  name                = "asp-dev-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "B1"

  tags = local.common_tags

}

resource "azurerm_linux_web_app" "webapp" {
  name                = "app-dev-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  service_plan_id = azurerm_service_plan.plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {

  }
  tags = local.common_tags
}

resource "azurerm_mssql_server" "sqlserver" {
  name                = "microsoftsqlserver-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  version = "12.0"

  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  tags = local.common_tags


}

resource "azurerm_mssql_database" "sqldb" {
  name      = "sqldb-dev"
  server_id = azurerm_mssql_server.sqlserver.id

  sku_name = "Basic"
  tags     = local.common_tags

}

