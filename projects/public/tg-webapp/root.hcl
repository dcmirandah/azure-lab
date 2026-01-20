locals {
	env_locals = try(read_terragrunt_config("env.hcl"), {})
	app_locals = try(read_terragrunt_config(find_in_parent_folders("app.hcl")), {})

	application = local.app_locals.locals.application
	environment = local.env_locals.locals.environment
}

inputs = {}

# Backend configuration
generate "backend" {
  path      = "backend_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "azurerm" {
    use_azuread_auth     = true
    use_msi              = false
		key                  = "tg-webapp-${local.application}-${local.environment}.terragrunt.tfstate"
    resource_group_name  = "${get_env("RESOURCE_GROUP_NAME")}"
		storage_account_name = "${get_env("STORAGE_ACCOUNT_NAME")}"
		container_name       = "${get_env("CONTAINER_NAME")}"
  }
}
EOF
}

# Provider configuration
generate "provider" {
	path      = "provider_override.tf"
	if_exists = "overwrite"
	contents  = <<EOF
terraform {
	required_providers {
		random = {
			source  = "hashicorp/random"
			version = "3.8.0"
		}
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "4.57.0"
		}
	}
}

provider "random" {}

provider "azurerm" {
	features {}
}
EOF
}
