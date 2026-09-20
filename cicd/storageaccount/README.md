# Storage Account Infrastructure Module

This module provisions the Azure Storage Account for RahulSite media uploads, securing it with a Private Endpoint.

## Resources Provisioned
- **Storage Account:** `rahulsitefiles` (Public network access disabled)
- **Blob Container:** `uploads` (Private access)
- **Private Endpoint:** Connects the Blob service securely to the `snet-endpoints` subnet.

## Usage
Run standard Terraform commands to deploy:
```bash
terraform init
terraform plan
terraform apply
```
