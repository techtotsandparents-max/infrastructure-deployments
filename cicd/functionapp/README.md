# Function App Infrastructure Module

This module provisions the Azure Linux Function App for RahulSite background tasks and microservices.

## Features
- Connects to the shared App Service Plan (`ASP-prometheusRG-8346`).
- Enables **VNet Integration** to the `snet-integration` subnet for secure outbound traffic to Key Vault, Cosmos DB, and Storage Account Private Endpoints.
- Enables **SystemAssigned Managed Identity**.
- Uses `rahulsitefiles` as its backing storage account (Note: in high-scale scenarios, a dedicated storage account is recommended).

## Usage
Run standard Terraform commands to deploy:
```bash
terraform init
terraform plan
terraform apply
```
