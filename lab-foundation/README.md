# lab-foundation

## Foundation Setup

1. Navigate to `lab-foundation/`.

2. Run the setup script: `./create-foundation.sh`. This will create the required management group, resource group, and storage account for Terraform state.

### Requirements for `create-foundation.sh`

- Azure CLI must be installed and you must be logged in (typically as a service principal): `az login --service-principal --username "<CLIENT_ID>" --password "<CLIENT_SECRET>" --tenant "<TENANT_ID>"`
- `jq` must be installed (for JSON parsing)

These env vars must be set:

- `FOUNDATION_NAME` — Name for the lab foundation and subscription
- `MANAGEMENT_GROUP_NAME` — Name of the management group to create/use
- `PARENT_MANAGEMENT_GROUP_NAME` — Name of the parent management group
- `BILLING_SCOPE_ID` — Azure billing scope ID for subscription creation
- `LOCATION` — Azure region for resource group and storage account
