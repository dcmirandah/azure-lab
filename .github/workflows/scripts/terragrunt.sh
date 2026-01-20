# !/bin/bash

# Configuration
source ../../../../secrets/LAB_CREDENTIALS.env

# Usage: ./terragrunt.sh [plan|apply|destroy] [part]
ACTION=${1:-plan}
PART=${2:-tg-webapp}
# Local usage: ➜ ../../../../.github/workflows/scripts/terragrunt.sh [plan|apply|destroy]

# Terragrunt action
case "$ACTION" in
  plan)
    terragrunt run --all -- plan
    ;;
  apply)
    terragrunt run --all -- apply
    ;;
  destroy)
    terragrunt run --all -- destroy
    ;;
  *)
    echo "Unknown action: $ACTION. Use plan, apply, or destroy."
    exit 1
    ;;
esac
