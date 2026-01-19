# !/bin/bash

# Configuration
source ../secrets/LAB_CREDENTIALS.env

# Usage: ./terraform.sh [plan|apply|destroy]
ACTION=${1:-plan}
# Local usage: ../.github/workflows/scripts/terraform.sh [plan|apply|destroy]

# Initialize Terraform
terraform init -backend-config=../secrets/backends/keyvault.json

# Terraform action
case "$ACTION" in
	plan)
		terraform plan -input=false -out=tfplan.out
		tf-summarize -tree tfplan.out
		;;
	apply)
		terraform apply -input=false -auto-approve
		;;
	destroy)
		terraform destroy -input=false -auto-approve
		;;
	*)
		echo "Unknown action: $ACTION. Use plan, apply, or destroy."
		exit 1
		;;
esac
