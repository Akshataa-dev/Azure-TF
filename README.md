# Azure Infrastructure Deployment using Terraform

## 1. Project Overview

This project demonstrates the deployment of a secure and scalable Azure infrastructure using **Terraform (Infrastructure as Code)**.

The infrastructure follows Azure security best practices by implementing private connectivity, network isolation, managed identity, secure secret management, and remote Terraform state storage.

The project uses Terraform to automate the provisioning and configuration of Azure resources.

## 2. Azure Resources Created

### Networking
- Azure Virtual Network (VNet)
- Private Endpoint Subnet: `snet-pe-dev` (`10.10.2.0/24`)
- Application Subnet: `snet-app-dev`
- Network Security Group: `nsg-app-dev`

### Storage
- Azure Storage Account
- Private Blob Container: `project-private-data`

### Security
- Azure Key Vault
- Key Vault Secrets
- System Assigned Managed Identity

### Compute
- Linux App Service Plan
- Linux Web App

### Database
- Azure SQL Server
- Azure SQL Database

## 3. Private Connectivity

Private Endpoints are configured for the following Azure services:

- Azure Storage Account
- Azure Key Vault
- Azure SQL Server

Private Endpoints provide private network connectivity to Azure services through the Virtual Network without requiring access through their public endpoints.

### App Service Networking

- Subnet delegation is configured to `Microsoft.Web/serverFarms`.
- App Service VNet Integration is configured with `snet-app-dev`.

This allows the Web App to communicate with resources accessible through the integrated Virtual Network.

## 4. Security Best Practices Implemented

The project follows these security practices:

1. **Remote Terraform State Storage:** Stores Terraform state remotely in Azure Storage for centralized state management.
2. **Private Blob Container:** Restricts public access to the project storage container.
3. **Managed Identity:** Enables the Web App to access supported Azure services without storing credentials in application code.
4. **Azure Key Vault:** Securely stores sensitive information such as passwords, connection strings, and API keys.
5. **Private Endpoints:** Provides private connectivity to Azure Storage, Key Vault, and SQL Server.
6. **Network Security Group:** Controls inbound and outbound network traffic according to configured security rules.
7. **Resource Tagging:** Implements consistent tagging for better resource identification and management.
8. **Sensitive Data Protection:** Excludes sensitive configuration files and Terraform state files from source control.

## 5. Terraform Project Structure

The project is organized into the following Terraform files:

| File | Description |
|---|---|
| `backend.tf` | Configures remote Terraform state storage. |
| `providers.tf` | Configures the Azure provider. |
| `versions.tf` | Specifies Terraform and provider version requirements. |
| `variables.tf` | Defines input variables used in the project. |
| `main.tf` | Contains the main Azure infrastructure resource configurations. |
| `outputs.tf` | Defines outputs generated after deployment. |
| `README.md` | Documents the project and deployment instructions. |
| `.gitignore` | Excludes sensitive and unnecessary files from Git. |

## 6. Prerequisites

Before deploying the infrastructure, ensure that the following tools are installed:

- Azure Subscription
- Azure CLI
- Terraform
- Git
- Access to the Azure subscription with the required permissions

Log in to Azure:

```bash
az login
```

## 7. Deployment Steps

Follow these steps to deploy the Azure infrastructure.

### Step 1: Initialize Terraform

Downloads the required providers and initializes the Terraform working directory.

```bash
terraform init
```

### Step 2: Validate Configuration

Checks the Terraform configuration files for syntax and configuration errors.

```bash
terraform validate
```

### Step 3: Generate Deployment Plan

Creates an execution plan to review the infrastructure changes before deployment.

```bash
terraform plan -out=tfplan
```

### Step 4: Display Deployment Plan

Displays the saved execution plan.

```bash
terraform show tfplan
```

### Step 5: Deploy Infrastructure

Applies the reviewed execution plan and provisions the Azure resources.

```bash
terraform apply tfplan
```

## 8. Terraform Outputs

After successful deployment, Terraform generates the following outputs:

- Resource Group Name
- Storage Account Name
- Key Vault Name
- Web App Hostname
- SQL Server Name
- SQL Database Name

These outputs help identify and access the deployed Azure resources.

## 9. Cleanup

To remove all infrastructure resources created through Terraform, execute:

```bash
terraform destroy
```

Review the proposed deletion before confirming.

**Note:** Ensure that important data is backed up before destroying resources. Remote state storage should also be handled carefully.

## 10. Git Best Practices

The following files and directories are excluded from source control using `.gitignore`:

```gitignore
.terraform/
terraform.tfvars
*.tfstate
*.tfstate.*
tfplan
```

This prevents sensitive configuration values, Terraform state files, and unnecessary generated files from being committed to the Git repository.

## 11. Conclusion

This project demonstrates how Terraform can be used to automate the deployment of secure Azure infrastructure.

By implementing Private Endpoints, Managed Identity, Azure Key Vault, Network Security Groups, and remote state management, the project follows important cloud security and infrastructure management practices.

It provides a foundation for building secure, scalable, and maintainable cloud environments using Infrastructure as Code.