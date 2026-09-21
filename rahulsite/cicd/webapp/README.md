# Web App Infrastructure Module

This module provisions the Azure App Service (Linux Web App) for RahulSite.

## Features
- Connects to the shared App Service Plan (`ASP-prometheusRG-8346`).
- Enables **VNet Integration** to the `snet-integration` subnet for secure outbound traffic to Key Vault, Cosmos DB, and Storage Account Private Endpoints.
- Enables **SystemAssigned Managed Identity**.
- Configures App Settings using Key Vault references.

## Usage
Run standard Terraform commands to deploy:
```bash
terraform init
terraform plan
terraform apply
```
