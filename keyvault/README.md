# Keyvault

## Usage

1. Configure secrets in `../secrets/LAB_CREDENTIALS.env` and backend in `../secrets/backends/keyvault.json`.
2. Use the unified script for all Terraform actions: `../.github/workflows/scripts/terraform.sh [plan|apply|destroy]`
3. The script sources credentials from `../secrets/LAB_CREDENTIALS.env` and uses the backend config at `../secrets/backends/keyvault.json`.
