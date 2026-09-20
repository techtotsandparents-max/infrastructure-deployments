# Network Infrastructure Module

This module provisions the foundational networking components for RahulSite.

## Resources Provisioned
- **Virtual Network (VNet):** `vnet-rahulsite`
- **Subnet (Integration):** `snet-integration` (Delegated to `Microsoft.Web/serverFarms` for Web App and Function App outbound traffic)
- **Subnet (Endpoints):** `snet-endpoints` (Used for Private Endpoints like Key Vault, Cosmos DB, and Storage)

## Usage
Run standard Terraform commands to deploy:
```bash
terraform init
terraform plan
terraform apply
```
