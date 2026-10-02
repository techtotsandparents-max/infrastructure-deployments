# 🏗️ Multi-Cloud Infrastructure Deployments

> **Everything-as-Code** mono-repo for provisioning and managing cloud infrastructure across **Azure**, **AWS**, and **GCP** using Terraform + GitHub Actions.

---

## Architecture Overview

```text
infrastructure-deployments/
├── modules/                          # Reusable, tested Terraform modules
│   ├── azure/                        # Azure provider modules
│   │   ├── webapp/                   # App Service + deployment slots
│   │   ├── cosmos-db/                # MongoDB + Gremlin APIs
│   │   ├── ai-search/                # Azure AI Search instance
│   │   ├── openai/                   # Azure OpenAI deployment
│   │   ├── function-app/             # Consumption/Premium plan functions
│   │   ├── storage/                  # Blob + lifecycle policies
│   │   ├── keyvault/                 # Secrets + access policies
│   │   ├── container-app/            # Container Apps Environment
│   │   ├── content-safety/           # Azure AI Content Safety
│   │   ├── document-intelligence/    # Azure AI Document Intelligence
│   │   └── network/                  # VNet + subnets + NSG + PE
│   ├── aws/                          # AWS provider modules
│   │   ├── lambda/                   # Function + layers + aliases
│   │   ├── ecs-fargate/              # Task definition + service
│   │   ├── s3/                       # Buckets + lifecycle + replication
│   │   ├── dynamodb/                 # Tables + GSI + DAX
│   │   ├── api-gateway/              # REST + WebSocket APIs
│   │   ├── step-functions/           # State machines
│   │   ├── bedrock/                  # Model access + prompt caching
│   │   ├── cognito/                  # User pools + identity pools
│   │   ├── cloudfront/               # Distribution + OAI
│   │   └── vpc/                      # VPC + subnets + NAT + SG
│   └── gcp/                          # GCP provider modules
│       ├── cloud-run/                # Service + revisions + traffic
│       ├── firestore/                # Database + indexes + rules
│       ├── bigquery/                 # Dataset + tables + views
│       ├── cloud-functions/          # Gen 2 functions
│       ├── pub-sub/                  # Topics + subscriptions + DLQ
│       ├── vertex-ai/                # Endpoints + fine-tuning jobs
│       ├── firebase/                 # Project + apps + extensions
│       ├── neo4j/                    # Marketplace deployment
│       └── vpc/                      # VPC + subnets + firewall
│
├── rahulsite/                        # Project 1 — Azure (RAG + AI Search)
├── foldermanager/                    # Project 5 — Azure (Doc Intelligence)
├── creatorvault/                     # Project 2 — AWS (Serverless Video AI)
├── stocksite/                        # Project 3 — GCP (Multi-Agent Trading)
├── kidsapp/                          # Project 4 — GCP Firebase (Adaptive AI)
│
├── .github/workflows/
│   ├── infra-azure.yml               # CI/CD for rahulsite + foldermanager
│   ├── infra-aws.yml                 # CI/CD for creatorvault
│   └── infra-gcp.yml                 # CI/CD for stocksite + kidsapp
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## Project Portfolio

| # | Project | Cloud | Key Resources | Monthly Budget |
|---|---------|-------|---------------|----------------|
| 1 | **rahulsite** | Azure | App Service, Cosmos DB (Mongo+Gremlin), AI Search, OpenAI, Content Safety, Key Vault | ≤ ₹3,500 (~$42) |
| 2 | **foldermanager** | Azure | App Service, Functions, Blob Storage, Document Intelligence, OpenAI, AI Search | ≤ ₹2,500 (~$30) |
| 3 | **creatorvault** | AWS | Cognito, Lambda, API Gateway, S3, DynamoDB, ECS Fargate, Step Functions, Bedrock, CloudFront | ≤ ₹2,000 (~$24) |
| 4 | **stocksite** | GCP | Cloud Run, Firestore, BigQuery, Pub/Sub, Vertex AI, Secret Manager, VPC | ≤ ₹6,500 (~$78) |
| 5 | **kidsapp** | GCP Firebase | Firebase (Web/Android/iOS), Firestore, Cloud Functions Gen2, Storage (TFLite) | ≤ ₹1,200 (~$15) |

---

## Pipeline Architecture

All pipelines follow the same pattern inspired by enterprise IaC organizations:

```text
  PR Created → fmt check → init → validate → plan → comment PR with plan
  Merge to main →                                  → apply
```

### Key Features
- **OIDC Authentication** — Zero static credentials; uses GitHub → Cloud OIDC federation
- **Module Validation** — Validates all shared modules before project deployment
- **PR Plan Comments** — Every PR gets an auto-generated Terraform plan comment
- **Path-Based Triggers** — Only runs when relevant files change
- **Plan Artifacts** — Saves plan output to ensure apply matches reviewed plan

---

## Authentication Setup (One-Time)

### Azure (OIDC Federation)

```bash
# Create App Registration for GitHub Actions
az ad app create --display-name "github-actions-terraform"

# Create Federated Credential
az ad app federated-credential create \
  --id <APP_OBJECT_ID> \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<GITHUB_ORG>/infrastructure-deployments:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

**GitHub Secrets Required:**
| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App Registration Client ID |
| `AZURE_SUBSCRIPTION_ID` | Target Azure Subscription |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |

### AWS (OIDC Federation)

```bash
# Create OIDC Provider
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com"

# Create IAM Role with trust policy for GitHub
aws iam create-role --role-name GitHubActionsTerraform \
  --assume-role-policy-document file://trust-policy.json
```

**GitHub Secrets Required:**
| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM Role ARN with OIDC trust |

### GCP (Workload Identity Federation)

```bash
# Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# Create Provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

**GitHub Secrets Required:**
| Secret | Description |
|--------|-------------|
| `GCP_WIF_PROVIDER` | Workload Identity Provider resource name |
| `GCP_SA_EMAIL` | Service Account email for Terraform |

---

## Terraform State Backends

| Cloud | Backend | Location |
|-------|---------|----------|
| Azure | Azure Storage | `stterraformrahultech/tfstate/{project}/terraform.tfstate` |
| AWS | S3 + DynamoDB Lock | `terraform-state-rahultech/{project}/terraform.tfstate` |
| GCP | GCS | `terraform-state-rahultech-gcp/{project}/terraform.tfstate` |

### Bootstrap State Backends

Before running Terraform for the first time, create the state backends:

```bash
# Azure
az group create -n rg-terraform-state -l centralindia
az storage account create -n stterraformrahultech -g rg-terraform-state -l centralindia --sku Standard_LRS
az storage container create -n tfstate --account-name stterraformrahultech

# AWS
aws s3api create-bucket --bucket terraform-state-rahultech --region us-east-1
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# GCP
gsutil mb -l asia-south1 gs://terraform-state-rahultech-gcp
gsutil versioning set on gs://terraform-state-rahultech-gcp
```

---

## Local Development

```bash
# Initialize a project
cd rahulsite
terraform init

# Plan changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars

# Destroy (careful!)
terraform destroy -var-file=terraform.tfvars

# Format all files
terraform fmt -recursive

# Validate configuration
terraform validate
```

---

## Cost Guardrails

Total portfolio monthly budget: **≤ ₹15,700 (~$189)**

Strategies used:
- Azure Cosmos DB **free tier** (400 RU/s)
- Azure AI Search & Content Safety on **F0 (free) SKU**
- AWS DynamoDB **PAY_PER_REQUEST** billing
- AWS ECS Fargate **scale-to-zero** (desired count = 0)
- CloudFront **PriceClass_100** (cheapest edge locations)
- GCP Cloud Run **min instances = 0** (scale to zero)
- GCP Cloud Functions **consumption billing**
- Firebase **Spark/Blaze** plan with spending alerts

---

## Contributing

1. Create a feature branch: `git checkout -b feat/add-new-module`
2. Make changes and run `terraform fmt -recursive`
3. Open a PR — the pipeline will auto-comment with the plan
4. Get approval, merge to `main` — apply runs automatically

---

## License

See [LICENSE](./LICENSE) file.
