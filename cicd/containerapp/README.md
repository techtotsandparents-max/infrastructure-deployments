# LLM Container App Module

This module provisions a Linux Web App for Containers, designed to host an offline LLM model.

## Features
- **Cost Savings:** Shares the exact same App Service Plan (`ASP-prometheusRG-8346`) as the Web App and Function App.
- **Security:** Configured with VNet Integration and IP Restrictions so that it can only be accessed internally by the Function App within the `snet-integration` subnet.
- **Docker Support:** Ready to pull a custom LLM Docker image from a registry (e.g., Azure Container Registry).

## Usage
Run standard Terraform commands to deploy:
```bash
terraform init
terraform plan
terraform apply
```
