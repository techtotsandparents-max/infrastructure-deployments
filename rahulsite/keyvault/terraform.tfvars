# ==========================================
# Azure Key Vault Infrastructure
# Deployment : RahulSite
# Environment: Production
# ==========================================

# ==========================================
# Resource Group & Location
# ==========================================
resource_group_name = "Rahulsite"
location            = "South India"

# ==========================================
# Key Vault Details
# Name must be globally unique, 3-24 alphanumeric + hyphens
# ==========================================
key_vault_name             = "kv-rahulsite-prod"
sku_name                   = "standard"
soft_delete_retention_days = 7
purge_protection_enabled   = false

# ==========================================
# Private Endpoint
# Attached to the same subnet as other PaaS resources
# Set private_ip_address to a free IP or null for dynamic
# ==========================================
virtual_network_name = "vnet-rahulsite"
subnet_name          = "snet-endpoints"

# Leave as null to auto-assign from the subnet during deployment
private_ip_address = null

# ==========================================
# Import Existing Resources to Terraform State
# ==========================================
import_to_state = false

# ==========================================
# Tags — injected at runtime by pipeline
# ==========================================
