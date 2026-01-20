# Usage

1. Configure secrets in `../secrets/LAB_CREDENTIALS.env`.
2. Move to the apps dir `cd app/`.
3. Use the unified script for all Terragrunt actions: `../../.github/workflows/scripts/terragrunt.sh [plan|apply|destroy]`
4. The script sources credentials from `../secrets/LAB_CREDENTIALS.env`.
