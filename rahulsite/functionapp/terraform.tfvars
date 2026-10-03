# ==========================================
# Azure Function App Infrastructure
# Deployment : RahulSite
# Environment: Production
# ==========================================

# ==========================================
# Resource Group & Location
# ==========================================
resource_group_name = "Rahulsite"
location            = "South India"

# ==========================================
# Function App Details
# ==========================================
function_app_name     = "rahulsite-func"
app_service_plan_name = "ASP-prometheusRG-8346"
node_version          = "20"

# ==========================================
# Networking (VNet Integration & PE)
# ==========================================
virtual_network_name    = "vnet-rahulsite"
subnet_integration_name = "snet-integration"
subnet_endpoints_name   = "snet-endpoints"

# Private Endpoint Static IP Assignment (Optional)
private_ip_address = null

# ==========================================
# Core Dependencies
# ==========================================
storage_account_name = "rahulsitefiles"
key_vault_name       = "kv-rahulsite-prod"



# ==========================================
# Managed Identity
# ==========================================
# Set to "" to use System Assigned only. Specify a name to append a User Assigned Identity.
identity_name = ""

# ==========================================
# Import Existing Resources to Terraform State
# ==========================================
import_to_state = false

# ==========================================
# Tags — injected at runtime by pipeline
# ==========================================
