# ==========================================
# Azure Cosmos DB Infrastructure
# Deployment : RahulSite
# Environment: Production
# ==========================================

# ==========================================
# Resource Group & Location
# Same RG and VNet as the web app and function app
# ==========================================
resource_group_name = "Rahulsite"
location            = "South India"

# ==========================================
# Cosmos DB Account
# Name must be globally unique, 3-44 lowercase alphanumeric + hyphens
# ==========================================
cosmosdb_account_name = "rahulsitecosmos"

# API type          : Azure Cosmos DB for MongoDB
cosmosdb_kind         = "MongoDB"

# Free Tier Discount: Opted IN
free_tier_enabled     = true

# Capacity mode     : Provisioned Throughput | use "Free" for Serverless
offer_type            = "Standard"

# Consistency level
consistency_level     = "Session"

# Workload Type     : Production
# Continuous30Days  = point-in-time restore, 30-day window
# Continuous7Days   = point-in-time restore, 7-day window (lower cost)
backup_tier           = "Continuous30Days"

# ==========================================
# Private Endpoint
# Attached to the same subnet as the web app PE
# Set private_ip_address to a free IP or null for dynamic
# ==========================================
virtual_network_name = "vnet-rahulsite"
subnet_name          = "snet-endpoints"

# Leave as null to auto-assign from the subnet during deployment
private_ip_address           = null
private_ip_address_secondary = null

# ==========================================
# Key Vault
# Existing KV shared with the web app
# Managed Identity will get:
#   Key Vault Crypto Officer — manage keys
#   Key Vault Secrets User   — read secrets
# ==========================================
key_vault_name                = "kv-rahulsite-prod"
key_vault_resource_group_name = "Rahulsite"

# ==========================================
# Managed Identity
# ==========================================
# Set to "" to use System Assigned only. Specify a name to append a User Assigned Identity.
identity_name = ""



# ==========================================
# Import Existing Resources to Terraform State
# Set import_to_state = true ONLY when running
# terraform import for pre-existing resources.
# ==========================================
import_to_state = false

# ==========================================
# Tags — injected at runtime by pipeline
# DO NOT add tags here — pipeline appends them, duplicates cause init failure
# ==========================================
