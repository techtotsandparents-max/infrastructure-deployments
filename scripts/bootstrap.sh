#!/usr/bin/env bash
# Bootstrap script for developer environments

set -e

echo "🚀 Bootstrapping local development environment..."

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo >&2 "❌ Terraform is required but it's not installed. Aborting."; exit 1; }
command -v git >/dev/null 2>&1 || { echo >&2 "❌ Git is required but it's not installed. Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "❌ jq is required but it's not installed. Aborting."; exit 1; }

echo "✅ All prerequisites installed."

# Set up Git hooks
if [ -d ".git" ]; then
  echo "🔧 Setting up Git pre-commit hooks..."
  cat << 'EOF' > .git/hooks/pre-commit
#!/usr/bin/env bash
echo "Running Terraform fmt..."
terraform fmt -recursive infrastructure-deployments/ || exit 1
EOF
  chmod +x .git/hooks/pre-commit
  echo "✅ Pre-commit hooks installed."
else
  echo "⚠️ Not a git repository. Skipping git hooks."
fi

echo "🎉 Bootstrap complete! You are ready to contribute."
