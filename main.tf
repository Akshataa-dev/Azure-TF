locals {
  common_tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Project     = "DevOpsAssignment"
    Owner       = "var.owner"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-dev"
  location = var.location

  tags = local.common_tags

}