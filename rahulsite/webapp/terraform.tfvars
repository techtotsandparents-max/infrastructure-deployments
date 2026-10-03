# ==========================================
# Azure Web App Infrastructure
# Deployment : RahulSite
# Environment: Production
# ==========================================

# ==========================================
# Resource Group & Location
# ==========================================
resource_group_name = "Rahulsite"
location            = "South India"

# ==========================================
# Web App Details
# ==========================================
webapp_name                          = "RahulSite"
app_service_plan_name                = "ASP-prometheusRG-8346"
app_service_plan_resource_group_name = "prometheusRG"
node_version                         = "24-lts"

# ==========================================
# Networking (VNet Integration & PE)
# ==========================================
virtual_network_name    = "vnet-rahulsite"
subnet_integration_name = "snet-integration"
subnet_endpoints_name   = "snet-endpoints"

# Private Endpoint Static IP Assignment (Optional)
# Leave as null to auto-assign from the subnet during deployment
private_ip_address = null

# ==========================================
# Key Vault Integration
# ==========================================
key_vault_name = "kv-rahulsite-prod"



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
