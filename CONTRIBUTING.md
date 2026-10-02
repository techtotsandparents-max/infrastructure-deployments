# Contributing to RahulTech

First off, thank you for considering contributing to RahulTech! 

## Monorepo/Polyrepo Architecture
Our infrastructure is managed as a **Monorepo** under `infrastructure-deployments/`. 
The applications are built as **Polyrepos** or independent folders within the root directory (e.g., `rahultech-web/`).

### Workflow
We follow the **GitHub Flow**:
1. Branch off `main` for all new features and bug fixes.
2. Branch naming convention: `feature/short-description` or `bugfix/issue-description`.
3. Commit your changes logically and with clear commit messages.
4. Push to your branch and open a Pull Request (PR) against `main`.

### Terraform Contribution Guidelines
All infrastructure is declared using Terraform. When contributing to `infrastructure-deployments/`:
- **Component pattern**: Each cloud component must be in its own directory (e.g., `vpc/`, `webapp/`) under the project's `cicd/` folder.
- **Variables**: Always define variables in `variables.tf` and supply environment-specific values via `terraform.tfvars`.
- **Validation**: Ensure you run `terraform fmt` and `terraform validate` before committing.
- **State**: State files are partitioned by project and cloud provider to limit blast radius. NEVER modify state manually.

### Pull Requests
1. Fill out the PR template completely.
2. CI pipelines will automatically run on your PR.
3. Code owners must review and approve your PR before it can be merged.
4. Infrastructure PRs will automatically run `terraform plan`. Review the plan output in the PR comments.
