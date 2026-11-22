terraform {
  backend "azurerm" {
    resource_group_name  = "rg-backend-dev"
    storage_account_name = "tfstatestorage11"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    subscription_id      = "cef6ed95-3763-4e71-8880-fc2703eaa808"
  }
}
