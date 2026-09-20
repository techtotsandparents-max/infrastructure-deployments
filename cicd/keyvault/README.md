# Key Vault Infrastructure Module

This module provisions the Azure Key Vault for RahulSite, securing secrets and connection strings.

## Resources Provisioned
- **Key Vault:** `kv-rahulsite-prod`
- **Private Endpoint:** Connects the Key Vault securely to the `snet-endpoints` subnet.
- **Network ACLs:** Configured to deny public access by default, only allowing traffic via the private endpoint or trusted Azure Services.

## Usage
Run standard Terraform commands to deploy:
```bash
terraform init
terraform plan
terraform apply
```
