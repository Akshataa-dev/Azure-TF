variable "location" {
  type    = string
  default = "southindia"
}

variable "owner" {
  type = string

}

variable "unique_suffix" {
  type = string
}


variable "storage_private_endpoint_name" {
  type    = string
  default = "pe-storage-dev"
}

variable "keyvault_private_endpoint_name" {
  type    = string
  default = "pe-kv-dev"

}

variable "webapp_private_endpoint_name" {
  default = "pe-webapp-dev"

}

variable "storage_subresource_name" {
  type    = string
  default = "blob"

}

variable "keyvault_subresource_name" {
  type    = string
  default = "vault"

}

variable "webapp_subresource_name" {
  type    = string
  default = "sites"

}
variable "sql_private_endpoint_name" {
  type    = string
  default = "pe-sql-dev"

}

variable "sql-private_service_connection_name" {
  type    = string
  default = "psc-sql-dev"

}
variable "webapp_vnet_integration_name" {
  type    = string
  default = "webapp-vnet-integration"

}
variable "sql_subresource_name" {
  type    = string
  default = "sqlServer"

}