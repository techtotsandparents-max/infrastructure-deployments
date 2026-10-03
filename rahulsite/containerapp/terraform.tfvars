# ==========================================
# Azure Container App (LLM) Infrastructure
# Deployment : RahulSite
# Environment: Production
# ==========================================

# ==========================================
# Resource Group & Location
# ==========================================
resource_group_name = "Rahulsite"
location            = "South India"

# ==========================================
# LLM Container App Details
# Sharing ASP for cost efficiency
# ==========================================
container_app_name    = "rahulsite-llm-container"
app_service_plan_name = "ASP-prometheusRG-8346"

# Docker Configuration
docker_image_name   = "myregistry.azurecr.io/offline-llm:v1"
docker_registry_url = "https://myregistry.azurecr.io"
model_path          = "/models/offline-llm.bin"

# ==========================================
# Networking (VNet Integration)
# Secures inbound traffic via IP Restrictions 
# allowing only the integration subnet
# ==========================================
virtual_network_name    = "vnet-rahulsite"
subnet_integration_name = "snet-integration"

# ==========================================
# Core Dependencies
# ==========================================
key_vault_name = "kv-rahulsite-prod"

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
