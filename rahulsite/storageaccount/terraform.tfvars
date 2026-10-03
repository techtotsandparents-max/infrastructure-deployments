# ==========================================
# Azure Storage Account Infrastructure
# Deployment : RahulSite
# Environment: Production
# ==========================================

# ==========================================
# Resource Group & Location
# ==========================================
resource_group_name = "Rahulsite"
location            = "South India"

# ==========================================
# Storage Account Details
# Name must be globally unique, 3-24 lowercase alphanumeric
# ==========================================
storage_account_name     = "rahulsitefiles"
account_tier             = "Standard"
account_replication_type = "LRS"

# ==========================================
# Private Endpoint (Blob Service)
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
