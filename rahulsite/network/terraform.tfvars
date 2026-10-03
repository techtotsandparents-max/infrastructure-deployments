# ==========================================
# Azure Virtual Network Infrastructure
# Deployment : RahulSite
# Environment: Production
# ==========================================

# ==========================================
# Resource Group & Location
# ==========================================
resource_group_name = "Rahulsite"
location            = "South India"

# ==========================================
# Virtual Network Details
# ==========================================
vnet_name          = "vnet-rahulsite"
vnet_address_space = ["10.0.0.0/16"]

# ==========================================
# Subnets
# integration: dedicated to Microsoft.Web/serverFarms
# endpoints  : dedicated to Private Endpoints
# ==========================================
subnet_integration_name             = "snet-integration"
subnet_integration_address_prefixes = ["10.0.1.0/24"]

subnet_endpoints_name             = "snet-endpoints"
subnet_endpoints_address_prefixes = ["10.0.2.0/24"]

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
