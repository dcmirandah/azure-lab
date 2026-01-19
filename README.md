# Azure Lab

This repository provides code (mainly bash and terraform) for setting up and managing an Azure Lab environment. It is designed to automate the creation of foundational resources, manage Azure subscriptions, and securely handle credentials for lab operations.

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

## License

See [LICENSE](LICENSE) for details.

## Contributing

Contributions are only welcome via issues.

If you have suggestions, bug reports, or feature requests, please open an issue to discuss them. Pull requests and direct code contributions are not accepted at this time because this repository is regularly synced from a private repository that runs GitHub Actions to keep logs private.
