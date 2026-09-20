# Cosmos DB Infrastructure Module

This module provisions the Azure Cosmos DB (MongoDB API) account for RahulSite, securing it with a Private Endpoint.

> **Note:** The existing `rahulsitecosmos` instance is on the Free Tier. The Free Tier does not support Private Endpoints in Azure. This Terraform script provisions standard tier routing with `public_network_access_enabled = false`.

## Resources Provisioned
- **Cosmos DB Account:** `rahulsitecosmos` (MongoDB API, Public network access disabled)
- **Private Endpoint:** Connects the MongoDB sub-resource securely to the `snet-endpoints` subnet.

## Usage
Run standard Terraform commands to deploy:
```bash
terraform init
terraform plan
terraform apply
```
