# RahulTech Sites & Infrastructure

This repository is the central hub for the RahulTech organization. It follows a **Monorepo for Infrastructure, Polyrepo for Apps** architecture. All cloud infrastructure definitions live centrally under `infrastructure-deployments/`, while application code lives in independent component directories (e.g., `rahultech-web/`, `foldermanager/`).

## 🏗️ Repository Skeleton

This repository implements a production-grade enterprise Git skeleton:

```text
.
├── .github/                        # GitHub Actions, PR/Issue Templates, CODEOWNERS
│   ├── workflows/                  # CI/CD Pipelines
│   ├── ISSUE_TEMPLATE/             # Standardized bug/feature templates
│   ├── PULL_REQUEST_TEMPLATE.md    # Standard PR checklist
│   └── CODEOWNERS                  # Automated PR reviewers mapping
├── docs/                           # Centralized documentation
│   ├── architecture/               # Architecture Decision Records (ADRs) and diagrams
│   └── runbooks/                   # Operational runbooks and incident response guides
├── scripts/                        # Utility scripts
│   └── bootstrap.sh                # Developer onboarding script (installs git hooks)
├── infrastructure-deployments/     # 🌍 Infrastructure Monorepo
│   ├── rahulsite/                  # Azure Infrastructure
│   ├── foldermanager/              # Azure Infrastructure (AI-powered)
│   ├── creatorvault/               # AWS Infrastructure (Serverless video processing)
│   ├── stocksite/                  # GCP Infrastructure (Data & ML pipelines)
│   └── kidsapp/                    # GCP Firebase Infrastructure
├── rahultech-web/                  # 🌐 Application Polyrepo: Corporate Website
├── CONTRIBUTING.md                 # Contribution guidelines
└── README.md                       # This file
```

## 🚀 Getting Started

1. **Bootstrap your environment**:
   Run the bootstrap script to set up pre-commit hooks (which auto-format Terraform files).
   ```bash
   ./scripts/bootstrap.sh
   ```
2. **Read the Architecture**:
   Review the [Multi-Cloud Blueprint](docs/architecture/multi_cloud_architecture_blueprint.md) to understand how the components interact across AWS, Azure, and GCP.
3. **Contribute**:
   Please read [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming conventions and the PR process.

## ☁️ Infrastructure Deployment Model

We utilize a **Component-by-Component** deployment strategy. Rather than deploying monolithic states, each cloud resource (e.g., VPC, Database, WebApp) is managed as an independent module with isolated state files. This ensures minimal blast radius and faster pipeline executions.

Each project directory under `infrastructure-deployments/` contains a `cicd/` folder holding these independent components, deployed by GitHub Actions workflows.

---
*Maintained by the RahulTech DevOps & Platform team.*
