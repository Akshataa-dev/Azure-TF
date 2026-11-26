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

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"

      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

}
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet_integration" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = azurerm_subnet.app.id

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

resource "azurerm_subnet_network_security_group_association" "priv_nsg" {
  subnet_id                 = azurerm_subnet.private.id
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

  administrator_login          = azurerm_key_vault_secret.sql_admin_username.value
  administrator_login_password = azurerm_key_vault_secret.sql_admin_password.value

  tags = local.common_tags


}

resource "azurerm_mssql_database" "sqldb" {
  name      = "sqldb-dev"
  server_id = azurerm_mssql_server.sqlserver.id

  sku_name = "Basic"
  tags     = local.common_tags

}

resource "azurerm_key_vault_secret" "sql_admin_username" {
  name         = "sql-admin-username"
  value        = "tbdl"
  key_vault_id = azurerm_key_vault.kv.id
  lifecycle {
    ignore_changes = [value]
  }

}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = "tbdl"
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value]
  }

}


resource "azurerm_private_endpoint" "storage_pe" {
  name                = var.storage_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psc-storage-dev"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = [var.storage_subresource_name]
    is_manual_connection           = false
  }
  tags = local.common_tags

}

resource "azurerm_private_endpoint" "keyvault_pe" {
  name                = var.keyvault_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psc-keyvault-dev"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = [var.keyvault_subresource_name]
    is_manual_connection           = false
  }
  tags = local.common_tags

}



resource "azurerm_private_endpoint" "webapp_pe" {
  name                = var.webapp_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "psc-webapp-dev"
    private_connection_resource_id = azurerm_linux_web_app.webapp.id
    subresource_names              = [var.webapp_subresource_name]
    is_manual_connection           = false

  }
  tags = local.common_tags

}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = var.sql_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = var.sql-private_service_connection_name
    private_connection_resource_id = azurerm_mssql_server.sqlserver.id
    subresource_names              = [var.sql_subresource_name]
    is_manual_connection           = false
  }

  tags = local.common_tags

}

